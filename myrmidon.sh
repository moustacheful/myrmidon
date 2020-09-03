#!/bin/bash
cwd=$(echo $(dirname $0))

# Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
config_file="${1:-"$HOME/.myrmidon-tasks.json"}"
tasks=$(cat $config_file)

# Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | jq ".[] | select(.name == \"$selected\")")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi

task_command=$(echo $task | jq ".command")
confirm=$(echo $task | jq ".confirm")

# Check whether we need confirmation to run this task
if [[ $confirm == "true" ]]; then
  # Chain the confirm command before executing the selected command
  confirm_script="$cwd/confirm.sh 'Confirm $selected?'"
  eval "$confirm_script && \"$task_command\" > /dev/null &"
else
  eval "\"$task_command\" > /dev/null &"
fi

notification=$(echo $task | jq ".notification")
if [ ! "$notification" == 'null' ]
then
    # extended notification text
    notification_command=$(echo $notification | jq -r '. | "notify-send \"\(.text)\" " ')
    # add options 
    notification_command=${notification_command}$(echo $notification | jq --raw-output ' del( . .text ) ' | sed '1d;$d' | sed 's/[", ]//g;s/:/=/;s/^/--/' | xargs)
    eval "$notification_command > /dev/null &"
fi
