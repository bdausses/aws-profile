#!/bin/zsh

# Determine if the script is being sourced or executed
(return 0 2>/dev/null)
if [ $? -eq 0 ]; then
    SOURCED=1
else
    SOURCED=0
fi

finish() {
    if [ $SOURCED -eq 1 ]; then
        return "$1"
    else
        exit "$1"
    fi
}

usage() {
  echo "Usage: $0 [-a] [-d] [-l]"
  echo "  -a   Add a new AWS profile"
  echo "  -d   Delete an existing AWS profile"
  echo "  -l   List available AWS profiles"
  echo "If no option is provided, you'll be prompted to select an existing AWS profile."
  finish 1
}

main() {
  # Parse options using getopts
  ACTION=""
  while getopts "adl" opt; do
    case "$opt" in
      a)
        ACTION="add"
        ;;
      d)
        ACTION="delete"
        ;;
      l)
        ACTION="list"
        ;;
      *)
        usage
        ;;
    esac
  done
  shift $((OPTIND -1))
   
  # Check if the script is being run directly (not sourced) and no parameters were provided.
  if [ $SOURCED -eq 0 ] && [ -z "$ACTION" ] && [ $# -eq 0 ]; then
      ACTION="list"
      echo
      echo "NOTE: The purpose of this script is to set environment variables for AWS CLI profiles. However, you"
      echo "      have called this script directly, so environment variables will not be set."
      echo "      To apply environment variables to your current shell, please source this script (e.g., 'source $0')."
      echo
  fi
   
  list_profiles() {
      awk 'BEGIN { max=0; count=0 }
           /^\[profile / {
               prof = $0;
               gsub(/^\[profile /, "", prof);
               gsub(/\]/, "", prof);
               getline comment;
               if (comment ~ /^#/) {
                   c = comment;
               } else {
                   c = "";
               }
               count++;
               profiles[count] = prof;
               comments[count] = c;
               if (length(prof) > max) max = length(prof);
           }
           END {
               header = sprintf("%2s | Profile Name", "Id");
               pad = max - length("Profile Name");
               for (j = 1; j <= pad; j++) {
                   header = header " ";
               }
               header = header " | Profile Comment";
               print header;
               sep = "";
               for (j = 1; j <= length(header); j++) {
                   sep = sep "-";
               }
               print sep;
               for (i = 1; i <= count; i++) {
                   printf "%2d | %s", i, profiles[i];
                   pad = max - length(profiles[i]);
                   for (j = 1; j <= pad; j++) {
                       printf " ";
                   }
                   if (comments[i] != "") {
                       printf " | %s", comments[i];
                   }
                   printf "\n";
               }
           }' ~/.aws/config
  }
  
  if [ "$ACTION" = "add" ]; then
      # --- Add Profile ---
      echo -n "Enter the new profile name: "
      read NEW_PROFILE_NAME
      echo -n "Enter the AWS access key ID: "
      read AWS_ACCESS_KEY_ID
      echo -n "Enter the AWS secret access key: "
      read -s AWS_SECRET_ACCESS_KEY
      echo
      echo -n "Enter the default region [us-east-1]: "
      read AWS_REGION
      AWS_REGION=${AWS_REGION:-us-east-1}
  
      timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      {
        echo "[profile $NEW_PROFILE_NAME]"
        echo "# Created by aws_profile.sh on $timestamp"
        echo "region = $AWS_REGION"
        echo "output = json"
        echo "cli_pager="
        echo ""
      } >> ~/.aws/config
  
      timestamp=$(date +"%Y-%m-%d %H:%M:%S")
      {
        echo "[$NEW_PROFILE_NAME]"
        echo "# Created by aws_profile.sh on $timestamp"
        echo "aws_access_key_id = $AWS_ACCESS_KEY_ID"
        echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY"
        echo ""
      } >> ~/.aws/credentials
  
      echo "Profile '$NEW_PROFILE_NAME' added to ~/.aws/config and ~/.aws/credentials."
      finish 0
  
  elif [ "$ACTION" = "delete" ]; then
      # --- Delete Profile ---
      # Extract available profiles from ~/.aws/config (profiles are denoted by [profile PROFILE_NAME])
      PROFILES_ARRAY=("${(@f)$(grep "^\[profile " ~/.aws/config | cut -d " " -f2 | tr -d ']')}")
      if [ ${#PROFILES_ARRAY[@]} -eq 0 ]; then
          echo "No profiles found in ~/.aws/config."
          finish 1
      fi
  
      echo
      echo "Available profiles to delete:"
      echo
      list_profiles
  
      echo
      echo -n "Select the profile number to delete (or press Enter to cancel): "
      read -r RAW_SELECTION
      while read -t 0.1 extra; do :; done
      PROFILE_SELECTION=$(echo "$RAW_SELECTION" | tr -d '[:space:]')
      if [ -z "$PROFILE_SELECTION" ]; then
         echo
         echo "No profile selected. Deletion cancelled."
         finish 0
      fi
      DELETE_PROFILE=${PROFILES_ARRAY[$PROFILE_SELECTION]}
  
      echo
      echo -n "Are you sure you want to delete profile '$DELETE_PROFILE'? (Y/n): "
      read CONFIRM
      if [ -z "$CONFIRM" ]; then
          CONFIRM="y"
      fi
      if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
          echo "Deletion cancelled."
          finish 0
      fi
  
      # Remove profile block from ~/.aws/config
      awk -v profile="[profile $DELETE_PROFILE]" '
        BEGIN {skip=0}
        $0 == profile {skip=1; next}
        /^\[/ {if(skip==1){skip=0}}
        skip == 0 {print}
      ' ~/.aws/config > ~/.aws/config.tmp && mv ~/.aws/config.tmp ~/.aws/config
  
      # Remove profile block from ~/.aws/credentials
      awk -v profile="[$DELETE_PROFILE]" '
        BEGIN {skip=0}
        $0 == profile {skip=1; next}
        /^\[/ {if(skip==1){skip=0}}
        skip == 0 {print}
      ' ~/.aws/credentials > ~/.aws/credentials.tmp && mv ~/.aws/credentials.tmp ~/.aws/credentials
  
      echo
      echo "Profile '$DELETE_PROFILE' has been deleted from ~/.aws/config and ~/.aws/credentials."
      finish 0
  
  elif [ "$ACTION" = "list" ]; then
      # --- List Profiles ---
      PROFILES_ARRAY=("${(@f)$(grep "^\[profile " ~/.aws/config | cut -d " " -f2 | tr -d ']')}")
      if [ ${#PROFILES_ARRAY[@]} -eq 0 ]; then
          echo
          echo "No profiles found in ~/.aws/config."
          finish 1
      fi
  
      echo "Available profiles are:"
      echo
      list_profiles
      finish 0
  
  else
      # --- Select Profile ---
      if [ -n "$AWS_PROFILE" ]; then
          echo
          echo "Your current AWS profile is set to: $AWS_PROFILE"
      else
          echo
          echo "You currently do not have an AWS profile set."
      fi
      echo
  
      PROFILES_ARRAY=("${(@f)$(grep "^\[profile " ~/.aws/config | cut -d " " -f2 | tr -d ']')}")
      if [ ${#PROFILES_ARRAY[@]} -eq 0 ]; then
          echo "No profiles found in ~/.aws/config."
          finish 1
      fi
  
      # Check if a positional parameter is provided and is numeric for auto-selection
      if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
           PROFILE_SELECTION="$1"
           if [ "$PROFILE_SELECTION" -gt ${#PROFILES_ARRAY[@]} ] || [ "$PROFILE_SELECTION" -lt 1 ]; then
                echo "Invalid profile selection number."
                finish 1
                return 1
           fi
           export AWS_PROFILE=${PROFILES_ARRAY[$PROFILE_SELECTION]}
           echo "Your AWS profile has been set to ${PROFILES_ARRAY[$PROFILE_SELECTION]}."
           finish 0
           return 0
      fi
  
      echo "Available profiles are:"
      echo
      list_profiles
  
      echo
      echo -n "Select which profile you want to use: "
      read -r RAW_SELECTION
      while read -t 0.1 extra; do :; done
      PROFILE_SELECTION=$(echo "$RAW_SELECTION" | tr -d '[:space:]')
  
      if [ -z "$PROFILE_SELECTION" ]; then
           echo "No profile selected, so nothing was done."
           finish 0; return 0
      elif ! [[ "$PROFILE_SELECTION" =~ ^[0-9]+$ ]]; then
           echo "Invalid input. Please select a valid profile number. Nothing was done."
           finish 0; return 0
      elif [ "$PROFILE_SELECTION" -gt ${#PROFILES_ARRAY[@]} ] || [ "$PROFILE_SELECTION" -lt 1 ]; then
           echo "Invalid profile selected, so nothing was done."
           finish 0; return 0
      fi
      export AWS_PROFILE=${PROFILES_ARRAY[$PROFILE_SELECTION]}
  
      echo
      echo "Your AWS profile has been set to ${PROFILES_ARRAY[$PROFILE_SELECTION]}."
      finish 0
  fi
}

main "$@"