# aws-profile.sh

`aws-profile.sh` is a Zsh script designed to simplify the management of AWS CLI profiles. It allows you to easily add, delete, list, and select AWS profiles from your configuration files without manually editing them. This script aims to streamline your workflow when working with multiple AWS accounts and regions.

## Features

- **Add Profiles:**
  Easily add a new AWS profile by entering the profile name, AWS access key, secret access key, and default region. The script automatically appends the new profile to both `~/.aws/config` and `~/.aws/credentials` with a timestamped comment.

- **Delete Profiles:**
  Remove an existing AWS profile from your configuration. The script lists all available profiles (with associated comments) and prompts you to confirm deletion.

- **List Profiles:**
  Display a neatly formatted table of available profiles, including an ID, profile name, and any comment present in the configuration file. This makes it easy to see profile metadata at a glance.

- **Select Profiles:**
  Set your current AWS profile interactively. You can either run the script without any options to be prompted or pass a numeric argument to automatically select a profile.

## Use Cases

- **Multi-Account Management:**
  If you manage multiple AWS accounts (e.g., production, staging, development, personal), this script helps you switch between profiles without the need to edit files manually.

- **Streamlined Workflows:**
  For developers and DevOps engineers, the ability to quickly add or remove profiles is a time-saver when spinning up or decommissioning environments.

- **CI/CD Pipelines:**
  Integrate profile management into your CI/CD workflows to automate the setup of AWS environments based on the appropriate credentials.

- **Learning and Troubleshooting:**
  The script's clear, comment-based output makes it easier to track when and how profiles were added, providing useful metadata for troubleshooting or auditing.

## Usage

### Adding a Profile

Run the script with the `-a` flag:

```sh
./aws-profile.sh -a
```

You'll be prompted to enter the profile name, AWS access key ID, secret access key (input is hidden), and the default region. The new profile will be appended to your configuration files.

### Deleting a Profile

Run the script with the `-d` flag:

```sh
./aws-profile.sh -d
```

The script will list available profiles with their associated comments. You can then select the profile number you wish to delete. You have the option to cancel deletion by pressing Enter.

### Listing Profiles

To simply view all available profiles, use the `-l` flag:

```sh
./aws-profile.sh -l
```

This displays a table with column headers (`Id | Profile Name | Profile Comment`), making it easy to review all your AWS profiles.

### Selecting a Profile

Without any options, the script will prompt you to select an existing profile interactively:

```sh
./aws-profile.sh
```

Alternatively, you can pass a numeric argument to auto-select the profile. For example, to select profile number 3:

```sh
./aws-profile.sh 3
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
