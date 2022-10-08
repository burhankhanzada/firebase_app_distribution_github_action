#!/bin/bash

if [ -z "$INPUT_SERVICE_ACCOUNT_KEY_JSON" ]; then

    echo "service_account_key_json is required"
    exit 1
else
    echo "Storing service_account_key_json as service_account_key.json"
    echo "$INPUT_SERVICE_ACCOUNT_KEY_JSON" >service_account_key.json

    echo "Exporting GOOGLE_APPLICATION_CREDENTIALS=service_account_key.json"
    export GOOGLE_APPLICATION_CREDENTIALS=service_account_key.json
fi

if ! [ -f ".firebaserc" ]; then
    echo ".firebaserc not found"

    echo "Consider adding .firebaserc to remove firebase error"

    echo "Extracting project_id from service_account_key.json"
    PROJECT_ID=$(jq .project_id service_account_key.json)

    echo "Setting firebase project to $PROJECT_ID"
    firebase use --add "$PROJECT_ID"
fi

uploadSingleArtifact() {

    if [ -z "$INPUT_APP_ID" ]; then
        echo "app_id is required"
        exit 1
    fi

    if [ -z "$INPUT_APP" ]; then
        echo "app is required"
        exit 1
    fi

    if [ -z "$INPUT_GROUPS" ]; then
        echo "groups is required"
        exit 1
    fi

    echo "Uploading single app"

    firebase appdistribution:distribute \
        $INPUT_APP \
        --app "$INPUT_APP_ID" \
        --groups "$INPUT_GROUPS"
}

uploadMultipleArtifacts() {

    echo "Storing multiple_apps_json as apps.json"
    echo "$INPUT_MULTIPLE_APPS_JSON" >apps.json

    echo "Using apps.json to upload muliple apps"

    APPS_COUNT=$(jq '.apps | length' apps.json)

    for ((i = 0; i < APPS_COUNT; i++)); do

        APP_ID=$(jq -r .apps["$i"].app_id apps.json)
        APP=$(jq -r .apps["$i"].app apps.json)
        TESTER_GROUPS=$(jq -r .apps["$i"].groups apps.json)

        echo Uploading App at index $i from location $APP for $TESTER_GROUPS groups

        firebase appdistribution:distribute \
            $APP \
            --app "$APP_ID" \
            --groups "$TESTER_GROUPS"
    done
}

if [ -n "$INPUT_MULTIPLE_APPS_JSON" ]; then
    uploadMultipleArtifacts
else
    uploadSingleArtifact
fi
