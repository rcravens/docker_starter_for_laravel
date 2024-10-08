#!/usr/bin/env bash

function command_run {
    if [ -z "$1" ] || [ "$1" == "help" ]; then
       command_help
       command_help_details
       exit 1
    fi

    TEMPLATE_TYPE="$1"
    export APP_NAME="$2"
    shift 2

    clear

    TEMPLATE_DIRECTORY="$TEMPLATES_DIRECTORY/$TEMPLATE_TYPE"
    if [ ! -d "$TEMPLATE_DIRECTORY" ]; then
      echo_red "The '$TEMPLATE_TYPE' template does not exist."
      command_help_details
      exit 1
    fi

    # Collect information for this template from the user
    # APP_NAME
    if [ -z "$APP_NAME" ]; then
      read -p "${GREEN}Enter the application short name [${TEMPLATE_TYPE}]: ${BLUE}" APP_NAME
      APP_NAME="${APP_NAME:-$TEMPLATE_TYPE}"
    fi
    export APP_DIRECTORY="$APPS_DIRECTORY/$APP_NAME"

    # Validate the CODE_REPO_URL format
#    echo "APP_NAME: $APP_NAME"
#    echo "APP_DIRECTORY: $APP_DIRECTORY"
#    echo "TEMPLATE_DIRECTORY: $TEMPLATE_DIRECTORY"

    # Force delete the existing application from the apps directory
    if [ -n "$1" ]; then
        if [ "$1" == "force" ] || [ "$1" == "-f" ] || [ "$1" == "-force" ] || [ "$1" == "--force" ]; then
            echo_red "Deleting apps directory: ${APP_DIRECTORY}"
            rm -rf "${APP_DIRECTORY}"
        fi
    fi

    # Create the new application from the template
    if [ ! -d "$APP_DIRECTORY" ]; then
      cp -a "$TEMPLATE_DIRECTORY" "$APP_DIRECTORY"
    else
      echo "An application with this name already exists. Try running the following:"
      echo_command "kit $APP_NAME start"
      exit 1
    fi

    export PATH_TO_CODE="$ROOT_DIRECTORY/../code/${APP_NAME}"

    # Call the init.sh script for the template to allow gathering of data an initializing the app
    if [ -f "$APP_DIRECTORY/bin/init.sh" ]; then
      # Run custom initialization script
      . "$APP_DIRECTORY/bin/init.sh"
    elif [ -f "$APP_DIRECTORY/envs/.env.template" ]; then
      # Run standard init based on .env.template file

      # For each of the existing environments, use the .env.template file
      # as a template to create a new environment file with the correct environment variables.
      ENV_DIRECTORY="${APP_DIRECTORY}/envs/*"
      for DIR in ${ENV_DIRECTORY}; do
        env="${DIR##*/}"

        echo_yellow "Updating environment: ${env}"

        ENV_TEMPLATE_FILE="${APP_DIRECTORY}/envs/.env.template"
        ENV_FILE="${APP_DIRECTORY}/envs/${env}/.env"

        update_env_using_template "$ENV_TEMPLATE_FILE" "$ENV_FILE" "$env"
      done
    fi

    # Reload the env files now that they are set by the init.sh
    unset HTTPS_ON_HOST # This prevents kit open from using stale data
    export ENV="dev"
    export ENV_FILE="$APP_DIRECTORY/envs/${ENV}/.env"
    if [ -f "$ENV_FILE" ]; then
      set -a # automatically export all variables
      source "$ENV_FILE"
      set +a
    fi

    echo_green "Application '$APP_NAME' initialized."

    if [ -f "$APP_DIRECTORY/bin/create.sh" ]; then
      . "$APP_DIRECTORY/bin/create.sh"
      #eval "./kit ${APP_NAME} ${ENV} create"
    fi

    echo_green "Application '$APP_NAME' started."
}

function command_help() {
  echo_command "kit new <template> <app name>" "Creates a new application from a template"
}

function command_help_details() {
    echo_divider
    echo "Available Templates:"
    for TEMP_DIR in $TEMPLATES_DIRECTORY/*
    do
      TEMPLATE=$(basename "$TEMP_DIR")
      echo_example "kit new $TEMPLATE <app name>"
    done
    echo_divider
}