#!/bin/bash
#
# This hook is to deter a user from committing directly to the master branch.
# It still allows the user to make the commit if they enter 'master' when
# prompted.
#
# To enable this hook, rename this file to "pre-commit" and place it in your
# .git/hooks/ directory.


echo_red() {
  local RED='\033[0;31m'
  local RESET='\033[0m' # Clear set colors
  local output=$@

  echo -e "${RED}$@${RESET}"
}

git_branch() {
  git symbolic-ref HEAD 2>/dev/null \
    | awk -F/ {'print $NF'}
}

is_current_branch_master() {
  [[ $(git_branch) = "master" ]]
}

check_input() {
  local input=$1
  if [[ "$input" = "master" ]]; then
    echo
    echo_red "You have made a commit directly to master!"
    exit 0
  else
    echo
    echo "Commit has been canceled."
    exit 1
  fi
}

print_warning_message() {
  echo_red "You are commiting directly to the master branch."
  echo "Type 'master' and hit return to confirm."
}

prompt_for_confirmation() {
  local input

  # Gives control to STDIN
  exec < /dev/tty

  while true; do
    read -p "Anything other than 'master' will cancel the commit: " input
    check_input $input
  done
}


if is_current_branch_master; then
  print_warning_message
  prompt_for_confirmation
else
  exit 0
fi
