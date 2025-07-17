#!/bin/bash
cwd=$(dirname "$0")

# Use ~/.myrmidon-tasks.json as default, otherwise use incoming paths
if [ "$#" -eq 0 ]; then
  config_files=("$HOME/.myrmidon-tasks.json")
else
  config_files=("$@")
fi

# Merge all provided config files into a single tasks array
tasks=$(jq -s add "${config_files[@]}")

# Pass tasks to rofi, and get the output as the selected option
selected=$(printf '%s' "$tasks" | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(printf '%s' "$tasks" | jq ".[] | select(.name == \"$selected\")")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi

task_command=$(printf '%s' "$task" | jq -r ".command")
confirm=$(printf '%s' "$task" | jq -r ".confirm")

# Check whether we need confirmation to run this task
if [[ $confirm == "true" ]]; then
  # Chain the confirm command before executing the selected command
  confirm_script="$cwd/confirm.sh 'Confirm $selected?'"
  eval "$confirm_script && \"$task_command\" > /dev/null &"
else
  eval "\"$task_command\" > /dev/null &"
fi