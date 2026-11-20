# Palakat demo app

The Palakat demo app: one Flutter app for Android phones, Android tablets and the web. It runs every module (finance, secretariat, membership, collaboration) on dummy data held in memory, with no backend. The build plan is `docs/build/README.md` and the conventions are `docs/build/CONVENTIONS.md`.

## Run

Flutter 3.47.8 through [fvm](https://fvm.app) (pinned in `.fvmrc`). From this folder:

| What | Command |
| --- | --- |
| Get packages | `fvm flutter pub get` |
| Run on web | `fvm flutter run -d chrome`, or `fvm flutter run -d web-server --web-port 8080` and open `http://localhost:8080` |
| Build web | `fvm flutter build web`, output in `build/web/`, served as static files (`python3 -m http.server -d build/web 8080`) |
| Run on Android | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter run -d <device-id>` |
| Debug APK | `JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home fvm flutter build apk --debug`, output `build/app/outputs/flutter-apk/app-debug.apk` |
| Analyze | `fvm flutter analyze` |
| Flow tests | `fvm flutter test` (one flow: `fvm flutter test test/flows/p03_pemilih_test.dart`) |

An Android phone shows the phone screens. An Android tablet (shortest side 600 or more) and the web show the web screens. Never run `fvm flutter clean`: it deletes `build/`, where the build notes live.

## The picker

The app opens on the persona picker, "Masuk sebagai". It is the only way in: there is no sign-in. Tap a persona to sign in as that person; the app opens their role home. Signing out (Akun, "Keluar") returns to the picker and keeps everything done so far, so a two-person flow works on one device: record as Meiske, sign out, check as Jefry, sign out, book as Meiske.

The 11 personas, under the picker's role headings:

| Heading | Persona | Post line |
| --- | --- | --- |
| Bendahara Jemaat | Meiske Lumentut | Bendahara Jemaat |
| Sekretaris Jemaat | Olvie Pangemanan | Sekretaris Jemaat |
| Operator | Yanti Sumual | Operator · menjalankan Penatua Kolom 2 |
| Pimpinan Jemaat yang berwenang | Pdt. Lidya Rondonuwu | Ketua Jemaat · Pimpinan Jemaat yang berwenang |
| | Pnt. Jefry Wowor | Pemeriksa kedua · Wakil Ketua BPMJ (checks every booking) |
| Penatua Kolom | Pnt. Hendrik Rumagit | Penatua Kolom 7 · Ketua Komisi Diakonia |
| | Sym. Greis Mamahit | Syamas Kolom 7 · menerima pelimpahan |
| Bendahara unit and committee officers | Deasy Tumbelaka | Bendahara Kolom 7 |
| | Dkn. Olga Tamba | Bendahara Komisi Diakonia · Akses terbatas Diakonia |
| | Sdr. Rivo Mandagi | Bendahara Panitia Natal 2026 · Ketua Pemuda |
| Anggota jemaat | Novita Wenas | Anggota jemaat · Kolom 7 |

What one persona does shows on every other screen and for every other persona.

## Dates and reset

The seed story moves with the real date: every seeded date is computed from today, so the open month is always the current one. Seasonal story names (Natal, Adven, Paskah) keep their drawn names.

Everything lives in memory. Reloading the page or restarting the app resets it to the seed; nothing is saved.

## Try it

1. Pick Meiske and open Keuangan from her home.
2. Record and save a draft.
3. Sign out and pick Pnt. Jefry Wowor. Mark the draft checked.
4. Sign out and pick Meiske again. Book it.
5. Sign out and pick Dkn. Olga Tamba. If the draft was Diakonia, she sees it.
