#!/bin/bash
# shellcheck disable=SC2086

setupFirebase() {
    if [[ -z $INPUT_SERVICE_ACCOUNT_KEY_JSON ]]; then

        echo "service_account_key_json is required"
        exit 1
    else
        echo "Storing service_account_key_json as service_account_key.json"
        echo $INPUT_SERVICE_ACCOUNT_KEY_JSON >service_account_key.json

        echo "Exporting GOOGLE_APPLICATION_CREDENTIALS=service_account_key.json"
        export GOOGLE_APPLICATION_CREDENTIALS=service_account_key.json
    fi

    if [[ ! -f ".firebaserc" ]]; then
        echo ".firebaserc not found"

        echo "Consider adding .firebaserc to remove firebase error"

        echo "Extracting project_id from service_account_key.json"
        PROJECT_ID=$(jq .project_id service_account_key.json)

        echo "Setting firebase project to $PROJECT_ID"
        firebase use --add $PROJECT_ID
    fi
}

setReleaseNotes() {
    echo "INPUT_RELEASE_NOTE:=$INPUT_RELEASE_NOTES"
    echo "INPUT_RELEASE_NOTES_FILE=$INPUT_RELEASE_NOTES_FILE"

    if [[ -f $INPUT_RELEASE_NOTES_FILE ]]; then
        release_notes=""
        release_notes_file=$INPUT_RELEASE_NOTES_FILE
    else
        release_notes_file=""
        release_notes=$INPUT_RELEASE_NOTES
    fi
}

uploadApp() {

    setReleaseNotes

    firebase appdistribution:distribute \
        $app \
        --app $app_id \
        --groups $groups \
        ${RELEASE_NOTES:+ --release-notes $release_notes} \
        ${RELEASE_NOTES_FILE:+ --release-notes-file $release_notes_file}
}

uploadSingleArtifact() {

    if [[ -z $INPUT_APP_ID ]]; then
        echo "app_id is required"
        exit 1
    fi

    if [[ -z $INPUT_APP ]]; then
        echo "app is required"
        exit 1
    fi

    if [[ -z $INPUT_GROUPS ]]; then
        echo "groups is required"
        exit 1
    fi

    echo "Uploading single app"

    app=$INPUT_APP
    app_id=$INPUT_APP_ID
    groups=$INPUT_GROUPS

    uploadApp
}

uploadMultipleArtifacts() {

    echo "Storing multiple_apps_json as apps.json"
    echo $INPUT_MULTIPLE_APPS_JSON >apps.json

    echo "Using apps.json to upload muliple apps"

    APPS_COUNT=$(jq '.apps | length' apps.json)

    for ((i = 0; i < APPS_COUNT; i++)); do

        app_id=$(jq -r .apps["$i"].app_id apps.json)
        app=$(jq -r .apps["$i"].app apps.json)
        groups=$(jq -r .apps["$i"].groups apps.json)

        echo Uploading App at index $i from location $app for $groups groups

        uploadApp

    done
}

setupFirebase

if [[ -n $INPUT_MULTIPLE_APPS_JSON ]]; then
    uploadMultipleArtifacts
else
    uploadSingleArtifact
fi
