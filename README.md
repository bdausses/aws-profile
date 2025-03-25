# aws-profile.sh

**Important:** This script is used to both select and set the `AWS_PROFILE` environment variable, but can also be used to manage (add and/or delete) AWS CLI profiles.  

If you want to use this script to select and set that `AWS_PROFILE` environment variable, you must **source** this script rather than running it directly. For example, use `source aws-profile.sh` instead of `aws-profile.sh`.

If you want to use the script to manage (add and/or delete) AWS CLI profiles, the sourcing does not need to be used.

Examples in this README assume you have added the script to a location in your PATH for ease of use.

## Features

* **Add Profiles:**
  Easily add a new AWS profile by entering the profile name, AWS access key, secret access key, and default region. The script automatically appends the new profile to both `~/.aws/config` and `~/.aws/credentials` with a timestamped comment.

* **Delete Profiles:**
  Remove an existing AWS profile from your configuration. The script lists all available profiles (with associated comments) and prompts you to confirm deletion.

* **Select Profiles:**
  Set your current AWS profile interactively or via an auto-selection feature by passing a numeric argument.  To effect the desired change in your current shell, you must source this script as noted in the Important note at the top of this document.

## Usage

### Adding a Profile

Run the script with the `-a` flag:

```sh
aws-profile.sh -a
```

You'll be prompted to enter the profile name, AWS access key ID, secret access key (input is hidden), and the default region. The new profile will be appended to your configuration files.

### Deleting a Profile

To delete an existing profile, run the script with the `-d` flag:

```sh
aws-profile.sh -d
```

The script will list available profiles with their associated comments and prompt you to select the profile number to delete.

### Selecting a Profile

Without any options, the script will prompt you to select an existing profile interactively. 

```sh
source aws-profile.sh
```

Alternatively, you can also pass a numeric argument to auto-select a profile if you know which profile you want loaded. For example, to select profile number 3:

```sh
source aws-profile.sh 3
```

If an invalid or empty selection is made, the script will display a friendly message and take no action.

## Installation

1. Clone or download the repository containing `aws-profile.sh`.
2. Make sure the script is executable:

    ```sh
    chmod +x aws-profile.sh
    ```

3. (Optional) Place the script in a directory that's in your PATH for easy access.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have ideas for new features or improvements, feel free to submit a pull request or open an issue.

## Disclaimer

Use this script at your own risk. Ensure you understand how it modifies your AWS configuration files before integrating it into your workflow.
