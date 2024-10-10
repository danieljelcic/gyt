# gyt - Git Shorthand Commands

## Overview

`gyt` is a Bash script that provides a set of shorthand commands for common Git operations. It's designed to streamline your Git workflow by offering easy-to-remember aliases for frequently used Git commands and sequences.

Shorthands are not implemented in order of any global relevance and are very much not exhaustive.

## Features

- Simplified Git commands with intuitive aliases
- Built-in help system for easy reference
- Bash auto-completion for commands and their aliases
- Customizable for your specific Git workflow

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/danieljelcic/gyt.git
   ```

2. Make the script executable:
   ```
   chmod +x gyt/bin.sh
   ```

3. Add the following line to your `~/.bashrc` or `~/.bash_profile`:
   ```
   source /path/to/gyt/bin.sh
   ```

4. Reload your shell configuration:
   ```
   source ~/.bashrc
   ```
   (or `source ~/.bash_profile` if you're using that instead)

## Usage

After installation, you can use `gyt` followed by a command or its alias. For example:

```
gyt tlm
```

This would switch to the main branch and pull the latest changes.

To see all available commands, use:

```
gyt help
```

For detailed help on a specific command, use:

```
gyt help <command>
```

Note that most commands use the git branch and remote names pre-defined at the top of the `bin.sh` file. The current values are standard, but should be changed as per a user's specific naming convention.

## Available Commands

- `tlm` or `to-latest-main`: Switch to main branch and pull latest changes
- `bflm` or `branch-from-latest-main`: Create a new branch from the latest main
- `catr` or `commit-all-to-remote`: Commit all changes and push to remote
- `fcb` or `freshen-current-branch`: Update current branch with latest changes from main

## Customization

You can customize `gyt` by editing the `bin.sh` file. You might want to:

- Change the `MAIN_BRANCH` variable if your main branch has a different name
- Modify existing commands to better suit your workflow
- Add new commands (see the instructions in the script)

## Contributing

Contributions to `gyt` are welcome! Here's how you can contribute:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes
4. Submit a pull request with a clear description of your changes

When adding new commands, please follow the existing pattern and update the help text accordingly.

## License

This project is licensed under the MIT License.

## Author

Daniel Jelcic

## Acknowledgments

I will make sure to acknowledge anyone who contributes to this mini project. Thank you in advance.