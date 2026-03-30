# Codemagic setup for Palakat mobile

This repository now includes a root `codemagic.yaml` for the Palakat mobile app.

## Workflows

- `palakat-mobile-ci`
  - Runs `dart pub get`, `flutter pub get`, code generation, `flutter analyze`, `flutter test`, and builds an Android APK.
- `palakat-mobile-android-release`
  - Builds a production Android App Bundle.
- `palakat-mobile-ios-release`
  - Builds a production iOS IPA with Codemagic signing.

## Required Codemagic environment group

Create an environment group named `palakat_mobile_env` and add at least this variable:

- `PALAKAT_APP_ENV_FILE`
  - The full sectioned `.env` contents for the mobile app.
  - Must include `[local]`, `[staging]`, and `[production]` sections.

Example format:

```env
[staging]
API_BASE_URL=https://staging-api.example.com
API_BASE_PORT=3000
API_BASE_VERSION=api/v1
```

## Android release signing

Codemagic must be configured with an Android keystore in **Code signing identities**.

Use the reference name in Codemagic so the workflow can fetch it automatically.

The mobile app release build now supports:

- `CI=true` with Codemagic keystore env vars
- Local `key.properties` if you want to sign release builds outside Codemagic

## iOS release signing

The iOS workflow uses Codemagic automatic signing for:

- Bundle identifier: `com.meimodev.palakat.palakat`
- Distribution type: `app_store`

Make sure your Apple Developer / App Store Connect integration is set up in Codemagic and the matching certificates and provisioning profiles are available.

## Notes

- The app reads the environment section at compile time from `PALAKAT_ENV`.
- The bundled runtime `.env` file is written during the Codemagic build before `flutter build` runs.
- The workflows assume the Flutter version from `.fvmrc` in `apps/palakat` (`3.41.5`).
