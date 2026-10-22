# iko_reliability

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Notes on common commands
flutter pub upgrade --major-versions
flutter pub outdated
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch / build
flutter pub get
flutter upgrade

flutter build windows

## Releases / updates (Velopack)

Releases are built with [Velopack](https://velopack.io/) and published to this
repo's GitHub Releases (no app store involved). The app auto-updates in-place
from the newest GitHub release (incl. delta updates); users of the previous
squirrel-based installers migrate by running the newest `*-Setup.exe` once.

Local release build:

    flutter build windows

    # one-time tool setup
    dotnet tool install -g vpk
    # rust is required to build the velopack_flutter native assets:
    # https://rustup.rs/

    # regenerate the release artifacts from the newest published release
    # (skip the download step for the very first velopack release)
    vpk download github --repoUrl https://github.com/jonathanmajh/iko_reliability

    vpk pack --packId iko_reliability_flutter --packVersion <version> `
        --packDir build/windows/x64/runner/Release `
        --mainExe iko_reliability_flutter.exe `
        --packTitle "IKO Reliability PM Tool" --packAuthors Jonathan `
        --icon iko_logo.ico --splashImage iko_logo.gif

Artifacts land in ./Releases (Setup.exe, portable zip, nupkg packages and
releases.win.json).

CI (`.github/workflows/release.yml`) does all of this automatically on tag
pushes: `git tag -a v1.4.10 -m "."` then `git push --follow-tags`.