#!/bin/bash
cwd=$(echo $(dirname $0))
tasks=$(cat $HOME/.myrmidon-tasks.json)

selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks: ")
task=$(echo $tasks | jq ".[] | select(.name == \"$selected\")")
task_command=$(echo $task | jq ".command")
confirm=$(echo $task | jq ".confirm")
confirm_script="$cwd/confirm.sh 'Confirm $selected?'"

if [ $confirm == "true" ]; then
  eval "$confirm_script && \"$task_command\" > /dev/null &"
else
  eval "\"$task_command\" > /dev/null &"
fi