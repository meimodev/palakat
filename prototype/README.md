# Palakat demo app

The Palakat demo app: one Flutter app for Android phones, Android tablets and the web. It runs every module on dummy data held in memory, with no backend. The build plan is `docs/build/README.md` and the conventions are `docs/build/CONVENTIONS.md`.

## The picker

The app opens on the persona picker, "Masuk sebagai". It lists the 11 personas of the seed story (Meiske Lumentut, Bendahara Jemaat; Pnt. Jefry Wowor, the second checker; and so on) under their roles. Tap one to sign in as that person; the app opens their role home. Signing out (Akun, "Keluar") returns to the picker and keeps everything done so far, so a two-person flow works on one device: record as Meiske, sign out, check as Jefry, sign out, book as Meiske.

Reloading the page or restarting the app resets everything.

## Run

Flutter 3.47.8 through [fvm](https://fvm.app) (pinned in `.fvmrc`). From this folder:

| What | Command |
| --- | --- |
| Get packages | `fvm flutter pub get` |
| Run on web | `fvm flutter run -d chrome` |
| Build web | `fvm flutter build web`, output in `build/web/`, served as static files |
| Run on Android | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter run -d <device-id>` |
| Debug APK | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter build apk --debug` |
| Analyze | `fvm flutter analyze` |
| Flow tests | `fvm flutter test` (one flow: `fvm flutter test test/flows/p03_pemilih_test.dart`) |

An Android phone shows the phone screens. An Android tablet (shortest side 600 or more) and the web show the web screens.
