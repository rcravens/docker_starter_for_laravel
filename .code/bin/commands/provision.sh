#!/usr/bin/env bash

function command_run {
    if [ -z "$2" ] && [ "$1" == "help" ]; then
       command_help
       command_help_details
       return 1
    fi

    SERVER=$ARGS

#    run_ansible_playbook "$SERVER" ssh
#    exit 1



  SERVER_DIRECTORY="${ROOT_DIRECTORY}/servers/${SERVER}"
  INVENTORY_FILE="${SERVER_DIRECTORY}/inventory.yml"
  SERVER_SETTINGS_FILE="${SERVER_DIRECTORY}/server_settings.yml"
  SSH_DIR="${SERVER_DIRECTORY}/.ssh"

  AWS_DIR="${SERVER_DIRECTORY}/.aws"
  if [ ! -d "$AWS_DIR" ]; then
    AWS_DIR="$HOME/.aws"
  fi

  echo "APP: ${APP}"
  echo "ROOT_DIRECTORY: ${ROOT_DIRECTORY}"
  echo "SERVER: ${SERVER}"
  echo "INVENTORY_FILE: ${INVENTORY_FILE}"
  echo "SERVER_SETTINGS FILE: ${SERVER_SETTINGS_FILE}"
  echo "SSH_DIR: ${SSH_DIR}"
  echo "AWS_DIR: ${AWS_DIR}"

  if [ -z "$SERVER" ]; then
    echo_red "Server name is required."
    exit 1
  fi

  if [ ! -f "$INVENTORY_FILE" ]; then
    echo_red "Inventory file not found: ${INVENTORY_FILE}"
    exit 1
  fi

  if [ ! -d "$SSH_DIR" ]; then
    echo_red "SSH directory not found: ${SSH_DIR}"
    exit 1
  fi

  if [ ! -d "$AWS_DIR" ]; then
    echo_red "AWS credential directory not found: ${AWS_DIR}"
    exit 1
  fi

#  docker run --rm --pull=always -it \
#    -v "$INVENTORY_FILE":/ansible/inventory.yml \
#    -v "$SERVER_SETTINGS_FILE":/ansible/server_settings.yml \
#    -v "$SSH_DIR":/root/.ssh \
#    -v "$AWS_DIR":/root/.aws \
#    rcravens/ansible ansible-playbook playbooks/sandbox.yml

  run_ansible "$SERVER" \
   -v "${SERVER_DIRECTORY}/swarm_settings.yml:/ansible/swarm_settings.yml" \
   playbooks/provision.yml

}

function command_help() {
  echo_command "kit provision <dest>" "Install necessary packages, configure Docker, and create a Docker Swarm."
}

function command_help_details() {
    echo_divider
    echo_red "Before running this command be sure to copy 'deploy-example.yml' to 'deploy.yml' and update deployment data."
    echo "Examples:"
    echo_example "kit provision prod" "Provision the ${RED}prod${RESET} servers."
    echo_example "kit make server prod" "Scaffold in the files to create the ${RED}prod${RESET} servers."
    echo_divider
}