#!/usr/bin/env bash

function func_rofi_confirm() {
  local MESSAGE INVERT YES NO OPTIONS RESPONSE

  MESSAGE="Confirm ${SELECTED} ?"
  MESSAGE=$(echo "${TASK}" | jq --exit-status --raw-output '.confirm.message | select (.!=null)' || echo "${MESSAGE}")
  INVERT=$(echo "${TASK}" | jq -e '.confirm.invert')
  YES=$(echo "${TASK}" | jq -er '.confirm.yes | select (.!=null)' || echo 'Yes')
  NO=$(echo "${TASK}" | jq -er '.confirm.no | select (.!=null)' || echo 'No')

  OPTIONS="${NO}\\n${YES}";
  [[ ${INVERT} == "true" ]] && OPTIONS="${YES}\\n${NO}";

  RESPONSE=$(echo -e "${OPTIONS}" | rofi -theme-str '#prompt { enabled: false; }' -dmenu -i -p "${MESSAGE} ")

  if [ "${RESPONSE}" == "${YES}" ]; then
    exit 0;
  else
    exit 1;
  fi
}

function myrmidon() {
  local CONFIG_FILE TASKS SELECTED TASK TASK_COMMAND CONFIRM

  # Use ~/.myrmidon-tasks.json as default, otherwise use incoming path
  CONFIG_FILE="${1:-"${HOME}/.myrmidon-tasks.json"}"
  TASKS=$(\cat "${CONFIG_FILE}")

  # Pass tasks to rofi, and get the output as the selected option
  SELECTED=$(echo "${TASKS}" | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
  [[ ${SELECTED} == '' ]] && exit 0

  TASK=$(echo "${TASKS}" | jq ".[] | select(.name == \"${SELECTED}\")")

  # Exit if no task was found
  if [[ ${TASK} == '' ]]; then
    echo "No task defined as '${SELECTED}' within config file."
    exit 1
  fi

  TASK_COMMAND=$(echo "${TASK}" | jq '.command')
  CONFIRM=$(echo "${TASK}" | jq '.confirm')

  # Check whether we need confirmation to run this task
  if [[ ${CONFIRM} != 'null' ]]; then
    func_rofi_confirm || exit 1
  fi

  eval "\"${TASK_COMMAND}\" > /dev/null &"
}

myrmidon "${@}"
