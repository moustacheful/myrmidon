#!/usr/bin/env bash

function func_rofi_confirm() {
  local OPTIONS UNSAFE RESPONSE

  [[ ${MESSAGE} == "null" ]] && MESSAGE="Confirm '${SELECTED}' ?"
  OPTIONS="No\\nYes";

  UNSAFE=$(echo "${TASK}" | jq ".unsafe")
  [[ ${UNSAFE} == "true" ]] && OPTIONS="Yes\\nNo";

  RESPONSE=$(echo -e "${OPTIONS}" | rofi -dmenu -i -p "${MESSAGE} ")

  if [ "${RESPONSE}" == "Yes" ]; then
    exit 0;
  else
    exit 1;
  fi
}

function myrmidon() {
  local CONFIG_FILE TASKS TASK SELECTED TASK_COMMAND CONFIRM CONFIRM_SCRIPT MESSAGE

  # Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
  CONFIG_FILE="${1:-"${HOME}/.myrmidon-tasks.json"}"
  TASKS=$(\cat "${CONFIG_FILE}")

  # Pass tasks to rofi, and get the output as the selected option
  SELECTED=$(echo "${TASKS}" | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
  TASK=$(echo "${TASKS}" | jq ".[] | select(.name == \"${SELECTED}\")")

  # Exit if no task was found
  if [[ ${TASK} == "" ]]; then
    echo "No task defined as '${SELECTED}' within config file."
    exit 1
  fi

  TASK_COMMAND=$(echo "${TASK}" | jq ".command")
  CONFIRM=$(echo "${TASK}" | jq ".confirm")
  MESSAGE=$(echo "${TASK}" | jq --raw-output ".message")

  # Check whether we need confirmation to run this task
  if [[ ${CONFIRM} == "true" ]]; then
    # Chain the confirm command before executing the selected command
    CONFIRM_SCRIPT="func_rofi_confirm '${MESSAGE}'"
    eval "${CONFIRM_SCRIPT} && \"${TASK_COMMAND}\" > /dev/null &"
  else
    eval "\"${TASK_COMMAND}\" > /dev/null &"
  fi
}

myrmidon "${@}"
