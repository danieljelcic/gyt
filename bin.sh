#!/bin/bash


# Set your main branch name (replace 'main' with 'master' or another name if needed)
MAIN_BRANCH="main"
REMOTE_ORIGIN="origin"
REMOTE_UPSTREAM="origin"

# ___ Instructions for adding new commands ________________
# 
# To add a new command:
# 1. Define a new function for your command above this comment.
#    The function should handle both execution and help:
#    my_new_command() {
#        if [ "$1" = "help" ]; then
#            cat << EOF
# Usage: gyt my_new_command [args]
#
# Description of what the command does.
#
# Args: [If applicable]
# EOF
#            return 0
#        fi
#        
#        # Your command logic here
#    }
# 2. In the 'gyt' function below:
#    a. Add a new case in the case statement for your command and its abbreviation.
#    b. Call your new function in that case.
# 3. In the '_gyt_autocomplete' function below:
#    a. Add the full command name to the 'cmds' variable.
#    b. Add the abbreviation to the 'abbrevs' variable.
#    Make sure to maintain the same order in both variables.
# 4. Update the 'show_help' function to include a brief description of your new command.
# 5. That's it! Your new command will now work with the 'gyt' function
#    and will appear in the autocomplete suggestions and help text.
# _________________________________________________________

# ___ Helper functions ____________________________________

confirm() {
    if [ "$#" -ne 1 ]; then
        message="Are you sure?"
    else
        message="$1"
    fi
    
    read -p "$message (y/n) " -n 1 -r confirm

    # Ensure the input is lowercase for easier comparison
    confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')

    if [[ $confirm =~ ^(y|yes)$ ]]; then
        return true
    elif [[ $confirm =~ ^(n|no)$ ]]; then
        return false
    else
        echo "Invalid input. Please enter y or n."
        exit 1
    fi
}

# ___ Commands ____________________________________________

# Script to switch to the main branch and pull the latest changes
to-latest-main() {
    if [ "$1" = "help" ]; then
        cat << EOF
Usage: gyt tlm, gyt to-latest-main

Switches to the main branch and pulls the latest changes.
This ensures your local main branch is up-to-date with the remote.
EOF
        return 0
    fi

    # Check if Git is initialized in the current directory
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not a Git repository."
    exit 1
    fi

    # Switch to the main branch
    git checkout "$MAIN_BRANCH" || {
    echo "Error: Failed to switch to the $MAIN_BRANCH branch."
    exit 1
    }

    # Pull the latest changes from the remote repository
    git pull "$REMOTE_ORIGIN" "$MAIN_BRANCH" || {
    echo "Error: Failed to pull changes from the remote repository."
    exit 1
    }

    echo "Successfully switched to $MAIN_BRANCH and pulled the latest changes from $REMOTE_ORIGIN."
}

# Creates a new branch from the latest main branch
branch-from-latest-main() {
    if [ "$1" = "help" ]; then
        cat << EOF
Usage: gyt bflm <branch_name>, gyt branch-from-latest-main <branch_name>

Creates a new branch from the latest main branch.
This ensures your new branch starts with the most recent changes.

Args: <branch_name> - The name of the new branch to create
EOF
        return 0
    fi

    if [ "$#" -ne 1 ]; then
        echo "Usage: gyt branch-from-latest-main <branch_name>"
        return 1
    fi
    local branch_name="$1"
    to-latest-main

    git checkout -b "$branch_name"
}

# Commits all changes and pushes to the remote repository
commit-all-to-remote() {
    if [ "$1" = "help" ]; then
        cat << EOF
Usage: gyt catr <message> [<remote>], gyt commit-all-to-remote <message> [<remote>]

Commits all changes and pushes to the remote repository.
This is a quick way to stage, commit, and push all changes in one command.

Args: <message> - The commit message
      [<remote>] - (Optional) The name of the remote to push to (default: $REMOTE_UPSTREAM)
EOF
        return 0
    fi

    if [ "$#" -ne 1 ]; then
        echo "Usage: gyt commit-all-to-upstream <commit-message> <remote-name>"
        return 1
    fi
    commit_message="$1"

    if [ "$#" -eq 2 ]; then
        local remote_name="$2"
    else
        local remote_name="$REMOTE_UPSTREAM"
    fi
    
    branch_name=$(git branch --show-current)

    git status

    confirmed=$(confirm "Are you sure you want to commit all of the above to $remote_name/$branch_name")

    if [ confirmed ]; then
        git add .
        git commit -m "$commit_message"
        git push "$remote_name" "$branch_name"
    else
        exit 1
    fi
}

# Updates the current branch with the latest changes from the main branch
freshen-current-branch() {
    if [ "$1" = "help" ]; then
        cat << EOF
Usage: gyt fcb, gyt freshen-current-branch

Updates the current branch with the latest changes from the main branch.
This helps keep your feature branch up-to-date with main.
EOF
        return 0
    fi

    branch_name=$(git branch --show-current)
    to-latest-main

    if [ "$branch_name" -eq "$MAIN_BRANCH" ] ; then
        exit 0
    fi

    git checkout "$branch_name"
    git merge "$MAIN_BRANCH"
}

# ___ Commands for getting help ___________________________

# Displays help information for all available commands
show_help() {
    cat << EOF
Git Shorthand Commands:
  gyt h, gyt help               : Show this help message
  gyt tlm, gyt to-latest-main   : Switch to main branch and pull latest changes
  gyt bflm <branch_name>, gyt branch-from-latest-main <branch_name>
                                : Create a new branch from the latest main
  gyt catr <message> [<remote>], gyt commit-all-to-remote <message> [<remote>]
                                : Commit all changes and push to remote
  gyt fcb, gyt freshen-current-branch
                                : Update current branch with latest changes from main

For more detailed information on a specific command, use:
  gyt help <command>
EOF
}

# ___ Main logic __________________________________________

gyt() {
    if [ "$#" -eq 0 ]; then
        show_help
    else
        all_args="$@"
        func="$1"
        shift # Remove function name from arguments
        case "$func" in
            h|help)
                if [ "$#" -eq 0 ]; then
                    show_help
                else
                    "$1" "help"
                fi
                ;;
            to-latest-main|tlm)
                to-latest-main
                ;;
            branch-from-latest-main|bflm)
                branch-from-latest-main "$@"
                ;;
            commit-all-to-remote|catr)
                commit-all-to-remote "$@"
                ;;
            freshen-current-branch|fcb)
                freshen-current-branch "$@"
                ;;
            *)
                echo "gyt: forwarding to git $all_args"
                git $all_args
                ;;
        esac
    fi
}

# Provides autocomplete functionality for the gyt command
_gyt_autocomplete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Define full commands and their abbreviations
    local cmds="help to-latest-main branch-from-latest-main commit-all-to-remote freshen-current-branch"
    local abbrevs="h tlm bflm catr fcb"

    if [[ ${COMP_CWORD} -eq 1 ]]; then
        local suggestions=()
        local i=0
        for cmd in $cmds; do
            abbrev=$(echo $abbrevs | cut -d' ' -f$((i+1)))
            if [[ "$cmd" == "$cur"* ]]; then
                suggestions+=("$cmd")
            elif [[ "$abbrev" == "$cur"* ]]; then
                suggestions+=("$abbrev ($cmd)")
            fi
            i=$((i+1))
        done
        COMPREPLY=($(printf "%s\n" "${suggestions[@]}" | sort))
    elif [[ ${COMP_CWORD} -eq 2 && "$prev" == "help" ]]; then
        COMPREPLY=($(compgen -W "$cmds $abbrevs" -- "$cur"))
    fi
}


# Register the autocomplete function
complete -F _gyt_autocomplete gyt

# Export the gyt function so it can be used as a command
export -f gyt
