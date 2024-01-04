#!/bin/bash

#set -x  # Uncomment for debugging

if [[ $# -ne 1 ]]; then
  echo "$0: usage: Requires the github public username that you want to clone and backup"
  exit 1
fi

username="$1"
backup_directory="github_backup_${username}_$(date +"%F")"

function check_exit() {
  [[ $? -ne 0 ]] && {
    echo "Error occurred"
    exit 1
  }
}

function get_repo_list() {
  repo_list=$(curl -s https://api.github.com/users/$username/repos | jq -r '.[].html_url')
  check_exit
  echo "$repo_list"
}

function clone_repos() {
  local repo_list="$1"
  local backup_dir="$2"
  
  cd ~
  check_exit
  
  mkdir -p "$backup_dir"
  check_exit

  cd "$backup_dir"
  check_exit

  for repo_url in $repo_list; do
    git clone -q "$repo_url" >/dev/null
    check_exit
  done

  cd "../"
  check_exit
  tar -cf $backup_dir.tar  $backup_dir >/dev/null
  check_exit
  echo "The github backup $backup_dir.tar is ready to be uploaded to either Google Drive or One Drive."
}

repo_list=$(get_repo_list)
clone_repos "$repo_list" "$backup_directory"
