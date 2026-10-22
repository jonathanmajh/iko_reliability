/// Velopack-based automatic application updates.
///
/// The update feed lives on GitHub Releases. Velopack expects the release
/// index (releases.win.json) and the update packages to be served from the
/// same folder, so the feed URL points at the release's asset folder:
/// `<repo>/releases/download/<tag>/`. The tag is resolved through the GitHub
/// API at startup, falling back to the tag of the installed version.
library;

import 'dart:async' show StreamSubscription;
import 'dart:convert' show jsonDecode;
import 'dart:io' show exit;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velopack_flutter/velopack_flutter.dart' as velopack;

import '../main.dart' show logger, navigatorKey;
import 'common.dart' show toast;

/// GitHub API endpoint returning the newest release of this repository.
const repoApiUrl =
    'https://api.github.com/repos/jonathanmajh/iko_reliability/releases/latest';

/// Webpage listing this repository's releases.
const repoReleasesUrl =
    'https://github.com/jonathanmajh/iko_reliability/releases';

/// Base URL of the release asset folders for this repository.
const repoBaseUrl = 'https://github.com/jonathanmajh/iko_reliability/releases';

/// Command line switches the Velopack runtime invokes this executable with
/// to perform install / update / uninstall hooks. The UI must not be shown
/// for those invocations.
const velopackHookArgs = [
  '--veloapp-install',
  '--veloapp-updated',
  '--veloapp-obsolete',
  '--veloapp-uninstall',
];

/// Velopack initialization future; makes [initializeAppUpdates] idempotent.
Future<void>? _initialized;

/// Builds the Velopack feed URL for the given GitHub release [tag].
String feedUrlForTag(String tag) => '$repoBaseUrl/download/$tag/';

/// Feed URL of the release matching the version this app was installed as.
/// Used when the GitHub API is unreachable.
Future<String> fallbackFeedUrl() async {
  final info = await PackageInfo.fromPlatform();
  return feedUrlForTag('v${info.version}');
}

/// Queries GitHub for the newest release and returns its Velopack feed URL.
Future<String> resolveUpdateFeedUrl() async {
  try {
    final response = await http
        .get(Uri.parse(repoApiUrl))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final tag = jsonDecode(response.body)['tag_name'];
      if (tag is String && tag.isNotEmpty) {
        return feedUrlForTag(tag);
      }
    }
  } catch (err) {
    logger?.d(
      'Update feed resolution failed; falling back to installed v-tag',
      error: err,
    );
  }
  return fallbackFeedUrl();
}

/// Processes a `--veloapp-*` invocation: initializes Velopack, which runs
/// the install/update/uninstall hook and terminates the process, so the UI
/// must never be started for these invocations.
Future<void> processVelopackHook() async {
  try {
    // The feed is of no concern while processing hooks, so fall back to the
    // installed tag instead of making a GitHub API request.
    await velopack.initializeVelopack(url: await fallbackFeedUrl());
  } catch (err) {
    logger?.w('Velopack unavailable during hook processing', error: err);
  }
  // The runtime exits the process itself while handling a hook; this is the
  // safety net for when it merely returns instead.
  exit(0);
}

/// Initializes Velopack with the update feed resolved from GitHub.
///
/// Idempotent; awaiting it guarantees that later Velopack API calls are safe
/// to make. Development (unpacked) builds and unsupported platforms fail
/// silently - auto-updating simply stays disabled there.
Future<void> initializeAppUpdates() async {
  if (kIsWeb) {
    return Future<void>.value();
  }
  _initialized ??= _initializeVelopack();
  return _initialized!;
}

Future<void> _initializeVelopack() async {
  try {
    await velopack.initializeVelopack(url: await resolveUpdateFeedUrl());
  } catch (err) {
    // Unpacked (development) builds and unsupported platforms fail here.
    logger?.w('Velopack unavailable; auto-updates disabled', error: err);
  }
}

/// Checks for application updates and shows the update dialog when one is
/// available. The update is downloaded from within the dialog and can be
/// applied immediately (with a restart) or silently on next app exit.
Future<void> checkForUpdate(BuildContext context) async {
  if (kIsWeb || !context.mounted) {
    return;
  }
  await initializeAppUpdates();
  velopack.UpdateInfo? info;
  try {
    info = await velopack.getLatestUpdateInfo();
  } catch (err) {
    logger?.w('Update check failed', error: err);
    return;
  }
  if (info == null) {
    return;
  }
  final targetVersion = info.targetFullRelease.version;
  final currentVersion = (await PackageInfo.fromPlatform()).version;
  if (!context.mounted) {
    return;
  }
  await showDialog(
    context: context,
    builder: (_) {
      return UpdateDialog(
        currentVersion: currentVersion,
        targetVersion: targetVersion,
      );
    },
  );
}

/// Update dialog: downloads the update with a progress bar and offers to
/// install it right away (restarting the app) or as soon as the app closes.
class UpdateDialog extends StatefulWidget {
  /// Constructs the update dialog with the installed and target versions.
  const UpdateDialog({
    required this.currentVersion,
    required this.targetVersion,
    super.key,
  });

  /// Version currently installed.
  final String currentVersion;

  /// Version offered by the update feed.
  final String targetVersion;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  StreamSubscription<int>? _progressSub;
  int _progress = 0;
  bool _downloading = false;
  bool _downloaded = false;
  String? _error;

  bool get _busy => _downloading || _downloaded;

  @override
  void dispose() {
    // Cancelling the progress subscription does not abort the download; the
    // runtime keeps filling its local package cache and installs it on the
    // next app start.
    _progressSub?.cancel();
    super.dispose();
  }

  void _startDownload() {
    setState(() {
      _error = null;
      _downloading = true;
    });
    _progressSub = velopack.checkAndDownloadUpdatesWithProgress().listen(
      (progress) {
        setState(() {
          _progress = progress;
        });
      },
      onError: (Object err) {
        if (!mounted) {
          return;
        }
        setState(() {
          _downloading = false;
          _error = err.toString();
        });
      },
      onDone: () {
        if (!mounted) {
          return;
        }
        setState(() {
          _downloading = false;
          _downloaded = true;
          _progress = 100;
        });
      },
    );
  }

  /// Stops this process and relaunches the app as the new version.
  Future<void> _installNow() async {
    try {
      await velopack.updateAndRestart();
    } catch (err) {
      logger?.w('Failed to apply update', error: err);
      if (mounted) {
        toast(navigatorKey.currentContext!, 'Failed to apply update: $err');
      }
    }
  }

  /// Applies the already-downloaded update as soon as the app exits and
  /// starts the new version afterwards.
  Future<void> _installOnExit() async {
    try {
      await velopack.waitExitThenUpdate(silent: true, restart: true);
    } catch (err) {
      logger?.w('Failed to schedule update on exit', error: err);
      if (mounted) {
        toast(navigatorKey.currentContext!, 'Failed to schedule update: $err');
      }
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
    toast(
      navigatorKey.currentContext!,
      'Update will be installed when the app closes.',
    );
  }

  Future<void> _openReleaseNotes() async {
    try {
      await launchUrl(
        Uri.parse(repoReleasesUrl),
        mode: LaunchMode.externalApplication,
      );
    } catch (err) {
      logger?.w('Failed to open release page', error: err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      title: const Text('Update Checker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Version ${widget.targetVersion} is available '
            '(installed: ${widget.currentVersion}).',
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(
              'Update download failed: $_error',
              style: TextStyle(color: Colors.red.shade700),
            ),
            const SizedBox(height: 8),
          ],
          if (_progress > 0 || _busy) ...[
            LinearProgressIndicator(
              value: _downloaded ? 1.0 : _progress / 100.0,
            ),
            const SizedBox(height: 6),
            Text(
              _downloaded
                  ? 'Download complete - ready to install.'
                  : _downloading
                  ? 'Downloading update... $_progress%'
                  : '',
            ),
          ],
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: _openReleaseNotes,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: const Text('Release notes'),
        ),
        TextButton(
          onPressed: _downloaded
              ? _installOnExit
              : () => Navigator.of(context).pop(),
          child: Text(_downloaded ? 'Later' : 'Close'),
        ),
        if (_error != null && !_downloading)
          TextButton(onPressed: _startDownload, child: const Text('Retry')),
        if (!_busy && _error == null)
          FilledButton(
            onPressed: _startDownload,
            child: const Text('Download update'),
          ),
        if (_downloaded)
          FilledButton(
            onPressed: _installNow,
            child: const Text('Install & restart'),
          ),
      ],
    );
  }
}
