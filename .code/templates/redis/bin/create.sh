#!/usr/bin/env bash

echo_yellow "Starting the application"
eval "./kit ${APP_NAME} start"

# Ensure host file has entry for this app
eval "./kit host ${APP_DOMAIN}"
