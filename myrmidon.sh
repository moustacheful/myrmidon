#!/bin/bash
cwd=$(echo $(dirname $0))

function print_usage {
  echo ""
  echo "Usage: $0 [[-c | --config] <filename>] [-h | --help] <tasks filename>"
  echo ""
  echo "  -c, --config <filename>   Configuration file, must be enclosed in quotes if contains spaces"
  echo "                            If not provided, configuration from default location will be used."
  echo ""
  echo "                            Place default configuration in:"
  echo "                               $config_file_default"
  echo ""
  echo "  -h, --help                Display this message"
  echo ""
  echo "  <tasks filename>          Tasks file, must be enclosed in quotes if contains spaces"
  echo "                            If file not porvided, tasks will be taken from the default list."
  echo ""
  echo "                            Plase default tasks in:"
  echo "                              $tasks_file_default"
  echo ""
  echo ""
  echo "Examples:"
  echo ""
  echo "  path/to/myrmidon.sh        Presents default tasks list using default configuration"
  echo ""
  echo "  path/to/myrmidon.sh power-tasks.json"
  echo "                             Presents power-tasks list using default configuration"
  echo ""
  echo "  path/to/myrmidon.sh -c power-config.json power-tasks.json"
  echo "                             Presents power-tasks list using power-tasks configuration"
  echo ""
  echo "For more information visit visit https://github.com/moustacheful/myrmidon"
  echo ""
  echo ""
  exit 0
}

# Set default config files following XDG guidelines
if [[ -z "${XDG_CONFIG_HOME}" ]]; then
  config_dir_default="$HOME/.config/myrmidon"
else
  config_dir_default="$XDG_CONFIG_HOME/myrmidon"
fi

config_file_default="$config_dir_default/config.json"
tasks_file_default="$config_dir_default/tasks.json"

# Parse parameters
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -c|-config)
  config_file="$2"
  shift
  shift
  ;;
  -h|--help)
  print_usage
  ;;
  *) # unknown options
  POSITIONAL+=("$1")
  shift
  ;;
esac
done
set -- "${POSITIONAL[@]}"

# If overriden configuration file is specified, make sure it exists and is readable
# Specifying a config file, or even having a default is not required, only test config parameter
if [[ -n "${config_file}"  ]] && [ ! -f $config_file ] && [ ! -r $config_file ]; then
  echo "Config file $config_file does not exist, or is not readable" 1>&2
  exit 1
fi

config_file="${config_file:-$config_file_default}"
tasks_file="${1:-$tasks_file_default}"

# Ensure passed in, or default tasks file exists and is readable
# Tasks file must always exist, test both tasks parameter and default

if [[ -z "${tasks_file}" ]] || ([ ! -f $tasks_file ] && [ ! -r $tasks_file ]); then
  echo "Tasks file $tasks_file does not exist, or is not readable" 1>&2
  exit 1
fi

tasks=$(cat $tasks_file)

# Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | jq ".[] | select(.name == \"$selected\")")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within tasks file."
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
