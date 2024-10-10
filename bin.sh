#!/bin/bash


# Set your main branch name (replace 'main' with 'master' or another name if needed)
MAIN_BRANCH="main"
REMOTE_ORIGIN="origin"
REMOTE_UPSTREAM="origin"

# ___ Instructions for adding new commands ________________
# 
# To add a new command:
# 1. Define a new function for your command above this comment.
# 2. In the 'gyt' function below:
#    a. Add a new case in the case statement for your command and its abbreviation.
#    b. Call your new function in that case.
# 3. In the '_gyt_autocomplete' function below:
#    a. Add the full command name to the 'cmds' variable.
#    b. Add the abbreviation to the 'abbrevs' variable.
#    Make sure to maintain the same order in both variables.
# 4. That's it! Your new command will now work with the 'gyt' function
#    and will appear in the autocomplete suggestions.
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
    branch_name=$(git branch --show-current)
    to-latest-main

    if [ "$branch_name" -eq "$MAIN_BRANCH" ] ; then
        exit 0
    fi

    git checkout "$branch_name"
    git merge "$MAIN_BRANCH"
}

# ___ Main logic __________________________________________

gyt() {
if [ "$#" -eq 0 ]; then
    echo "Usage: gyt <function_name> [arguments...]"
else
    func="$1"
    shift  # Remove function name from arguments

    if [ "$func" = "to-latest-main" ] || [ "$func" = "tlm" ]; then
        to-latest-main
    elif [ "$func" = "branch-from-latest-main" ] || [ "$func" = "bflm" ]; then
        branch-from-latest-main "$@"
    elif [ "$func" = "commit-all-to-remote" ] || [ "$func" = "catr" ]; then
        commit-all-to-remote "$@"
    elif [ "$func" = "freshen-current-branch" ] || [ "$func" = "fcb" ]; then
        freshen-current-branch "$@"
    else
        echo "Invalid function name: $func"
    fi
fi
}

_gyt_autocomplete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Define full commands and their abbreviations
    local cmds="to-latest-main branch-from-latest-main commit-all-to-remote freshen-current-branch"
    local abbrevs="tlm bflm catr fcb"

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
    fi
}

# Register the autocomplete function
complete -F _gyt_autocomplete gyt

# Export the gyt function so it can be used as a command
export -f gyt
