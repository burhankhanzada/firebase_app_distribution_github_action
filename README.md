# firebase_app_distribution_github_action

Github action that uploads single or multiple apps to firebase app distribution
with glob pattern support

## Inputs

## `service_account_key_json`

**Required** Google cloud platform project service account key (json).

## `app_id`

Firebase App id.

## `app`

App to upload (.apk or .ipa)

## `groups`

Groups of testers seperated by comma

## `release_notes`

Release notes string

## `release_notes_file`

Release notes file (txt)

## `multiple_apps_json`

Json file for multiple apps

```json
{
    "apps": [
        {
            "app_id": "1:23456789:android:123456789123456789",
            "app": "/app.apk",
            "groups": "all",
            "release_notes": "Single app at project root release notes"
        },
        {
            "app_id": "1:23456789:android:123456789123456789",
            "app": "/build/app.apk",
            "groups": "testers,qa",
            "release_notes_file": "release_notes.txt"
        }
    ]
}
```

## with glob pattern

To upload app with version in name like 'app-admin-1.0.0.apk' use glob pattern.

```json
{
    "apps": [
        {
            "app_id": "1:23456789:android:123456789123456789",
            "app": "/build/app-admin-**.apk",
            "groups": "all"
        },
        {
            "app_id": "1:23456789:android:123456789123456789",
            "app": "/build/app-user-**.apk",
            "groups": "testers,qa"
        }
    ]
}
```

## Example usage

```yml
jobs:
  single_app_root:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@main

      - name: Single app at project root
        uses: burhankhanzada/firebase_app_distribution_github_action@main
        with:
          service_account_key_json: ${{ secrets.SERVICE_ACCOUNT_KEY_JSON }}
          app_id: ${{ secrets.FIREBASE_APP_ID }}
          app: app.apk
          groups: all
          release_notes: "Single app at project root release notes"

  single_app_path:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@main

      - name: Single app at specific path
        uses: burhankhanzada/firebase_app_distribution_github_action@main
        with:
          service_account_key_json: ${{ secrets.SERVICE_ACCOUNT_KEY_JSON }}
          app_id: ${{ secrets.FIREBASE_APP_ID }}
          app: /build/app.apk
          groups: all
          release_notes_file: "release_notes.txt"

  multiple_apps:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@main

      - name: Multiple apps with json
        uses: burhankhanzada/firebase_app_distribution_github_action@main
        with:
          service_account_key_json: ${{ secrets.SERVICE_ACCOUNT_KEY_JSON }}
          multiple_apps_json: ${{ secrets.APPS_JSON }}
```
