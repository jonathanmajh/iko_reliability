# AGENTS.md

## What this is

Windows-only Flutter desktop app (package `iko_reliability_flutter`, "IKO Reliability PM Tool") that extracts/uploads PM (preventive maintenance) data to IBM Maximo via OSLC/REST. Local state lives in two drift/sqlite databases. Feature specs and plans are in `plans/`.

## Commands

- `flutter pub get` first.
- Codegen: `dart run build_runner build --delete-conflicting-outputs`. Regenerates `lib/routes/route.gr.dart` (auto_route), `lib/bin/db_drift.g.dart` and `lib/items/item_db.g.dart` (drift). Run it after adding a route in `lib/routes/route.dart` or changing a table; the `.g.dart` files ARE committed, so include regenerated output in changes.
- `flutter analyze` (excludes `web/**`, `windows/**`); `flutter test` (all three files in `test/`).
- Formatting: the repo IS `dart format`-clean since the formatting-only commit `1c9d824` (tall style, Dart 3.13). ALWAYS finish an edit by running `dart format` on the files you touched — the user's IDE applies the same formatter on save, so unformatted hand whitespace gets churned there otherwise. Never hand-place continuation indents; let the formatter own whitespace. `flutter analyze` reports 5 pre-existing infos (avoid_print x2, unrelated_type_equality_checks x2, unnecessary_brace_in_string_interps); your change must not add new analyzer issues rather than needing a fully green run.
- Tests quirks:
  - `test/widget_test.dart` pumps the app at 1920x1080 because desktop layouts overflow at the default 800x600, and tolerates a known home drawer Row overflow (see comments there).
  - `test/extract_import_template_test.dart` is a bare-main assert harness (`ok:` prints, throws `StateError`); it runs under `flutter test` but also standalone via `dart run test/extract_import_template_test.dart`.
- `flutter run -d windows`; release build `flutter build windows` requires Rust installed (rustup) to build `velopack_flutter` native assets.

## CI / releases

- `.github/workflows/release.yml` is the only workflow; it runs only on `v*` tag pushes. No test CI exists — run `flutter analyze` and `flutter test` locally before pushing.
- Release: bump `version:` in `pubspec.yaml`, then `git tag -a v<version> -m "."` and `git push --follow-tags`. The tag minus `v` becomes the Velopack packVersion, and the updater's fallback feed derives `v${packageInfo.version}` from pubspec — pubspec version and tag must match.
- `vpk download github ...` pulls the previous release for delta packages and is expected to fail on the first Velopack release (CI marks it `continue-on-error`).
- Dependabot opens daily pub bumps. Several pins are deliberate — do not merge upgrades blindly.

## Deliberate dependency pins (see pubspec.yaml comments)

- `dropdown_search` 7.x — 8.x+ draws on the standalone `material_ui` fork and crashes at runtime ("No Material widget found") because the app uses SDK `flutter/material`.
- `file_picker` 11.x and `package_info_plus` 9.x — 12+/10+ need win32 ^6, conflicting with `super_drag_and_drop`'s transitive win32 5.x.
- `printing` — upgrade waits on upstream worker-thread printing fix (DavBfr/dart_pdf PR #1985); TODOs in pubspec and `lib/print/wo_print_page.dart`.

## Architecture notes

- Entry `lib/main.dart`: global singletons `database` (MyDatabase, "reliability") and `itemDatabase` (ItemDatabase, "item"); all ChangeNotifier providers are registered here.
- Drift tables in `lib/bin/db_drift.dart` (`schemaVersion` 4) and `lib/items/item_db.dart`. When changing tables, bump `schemaVersion` AND add an `onUpgrade` migration in `MyDatabase.migration`.
- The item DB is a snapshot downloaded from `https://iko-proxy.jonathanmajh.workers.dev/program.zip` and wiped+replaced whenever remote `/.version` differs. DB files land in `<Documents>\ReliabilityApp\iko_reliability.db` / `iko_item.db` (`lib/admin/connections/` holds platform-specific drift connections).
- Maximo environments and API base URLs: `maximoServerDomains` in `lib/bin/consts.dart` (default `MASPROD`; `TEST2 8.11` used by tools). Login credentials are entered in-app and stored in the drift `LoginSettings` table under `ENV_USERID`/`ENV_PASS`/`ENV_APIKEY` keys — never hardcode API keys.
- WO Print feature flow: `lib/print/wo_fetch.dart` (Maximo OSLC, paginate via `oslc.pageSize` + follow `responseInfo.nextPage`) → `wo_assemble.dart` → `wo_packet.dart` renders; page UI in `wo_print_page.dart`.
- `web/`, `kIsWeb` guards, and `logger_web.dart` vs `logger_windows.dart` are residual web support; the primary target is Windows. Keep conditional imports compiling, but don't invest in web behavior.
- Release builds must bundle `sqlite3.dll`: `windows/CMakeLists.txt` copies build-hook native assets into the bundle; release CI fails if it's missing (app would crash at startup with "Couldn't resolve native function sqlite3_initialize").

## Never commit

- `tool/prod_data/` (PROD Maximo dump data, gitignored), `lib/print/*.pdf`, `/Releases*/` (Velopack build outputs).

## Diagnostics (usage documented in each file's header)

- `dart run tool/wo_print_batch_smoke.dart` — offline WO print render smoke test.
- `set IKO_TEST2_APIKEY=<key>` then `dart run tool/wo_print_sample.dart` — fetches a real WO tree from TEST2 and renders a print pack.
- `dart run tool/pdf_raster.dart <in.pdf> --pages 1,2 --out build/tmp/p` — rasterizes PDFs via the app's pdfium.dll for layout inspection (BMP output; header shows a PowerShell PNG conversion snippet).
- `tool/*.ps1` — PowerShell probes for Maximo OSLC paging / PROD dumps.
