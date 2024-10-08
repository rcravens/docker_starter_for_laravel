#!/usr/bin/env bash

  # Create code directory outside of image to share as a volume
  if [ ! -d "${PATH_TO_CODE}" ]; then
      echo_yellow "Creating directory ${PATH_TO_CODE}"
      mkdir -p "${PATH_TO_CODE}"
  else
      echo_yellow "Code directory already exists at: ${PATH_TO_CODE}"
  fi

  # Create initial code
  if [ -n "${CODE_REPO_URL}" ]; then
      # Clone an existing application
      echo_yellow "Cloning Project From: ${CODE_REPO_URL}"
      git clone "${CODE_REPO_URL}" "${PATH_TO_CODE}"
  fi

echo_yellow "Starting the application"
eval "./kit ${APP_NAME} start"
# HACK: Don't understand why the original start fails to mount the volume
#echo_yellow "Restarting the container to ensure the volume is mounted correctly....hackety hack..."
#eval "./kit ${APP_NAME} stop"
#eval "./kit ${APP_NAME} start"

# Ensure host file has entry for this app
eval "./kit ${APP_NAME} host"

# Call the build.sh script for the template
if [ -f "$APP_DIRECTORY/bin/commands/build.sh" ]; then
  echo_yellow "Found a build file for this template."
  eval "./kit ${APP_NAME} build"
else
  echo_yellow "No build file found for this template."
fi

echo_yellow "Opening browser tab"
eval "./kit ${APP_NAME} open"
