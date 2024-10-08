#!/usr/bin/env bash

function command_run {
    if [ "$ARGS" == "help" ]; then
       command_help
       command_help_details
       return 1
    fi

    run_docker_compose down
    run_docker_compose up -d "${ENTRY_SERVICE}"
}

function command_help() {
  echo_command "kit <app> restart" "Stop and start the application"
}

function command_help_details() {
    echo_divider
    echo "Examples:"
    echo_example "kit laravel restart" "Stop and restart the ${RED}laravel${RESET} application"
    echo_divider
}