import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:drun/drun.dart';
import 'package:dexeca/dexeca.dart';
import 'package:path/path.dart' as p;

Future<void> main(argv) async => drun(argv);

/// Gets things ready to perform a release.
///
/// * [nextVersion] Should be a valid semver version number string.
///   see: https://semver.org
///
///   This version number will be used to replace the `0.0.0-semantically-released`
///   placeholder in the files `./pubspec.yaml`, `./bin/drun.dart` &
///   `./lib/src/executor.dart`.
///
/// * [assetsDir] Files in this location will be uploaded to the new Github Release
Future<void> releasePrepare(
  String nextVersion, [
  String assetsDir = './github-assets',
]) async {
  await _searchReplaceVersion(File(p.absolute('pubspec.yaml')), nextVersion);
}

/// Actually publishes the package to https://pub.dev.
///
/// Beaware that `pub publish` does not really support being used inside a CI
/// pipeline yet. What this does is uses someone's local OAUTH creds which is a
/// bit hacky.
///
/// see: https://github.com/dart-lang/pub/issues/2227
/// also: https://medium.com/evenbit/publishing-dart-packages-with-github-actions-5240068a2f7d
///
/// * [nextVersion] Should be a valid semver version number string.
///   see: https://semver.org
///
/// * [dryRun] If supplied then nothing will actually get published.
///
/// * [accessToken] Get this from your local `credentials.json` file.
///
/// * [refreshToken] Get this from your local `credentials.json` file.
///
/// * [oAuthExpiration] Get this from your local `credentials.json` file.
Future<void> releasePublish(
  String nextVersion,
  bool dryRun, [
  @Env('PUB_OAUTH_ACCESS_TOKEN') String accessToken = '',
  @Env('PUB_OAUTH_REFRESH_TOKEN') String refreshToken = '',
  @Env('PUB_OAUTH_EXPIRATION') int oAuthExpiration = 0,
]) async {
  String tmpDir;
  var gitIgnore = File(p.absolute('.gitignore'));

  try {
    // Copy our custom .pubignore rules into .gitignore
    // see: https://github.com/dart-lang/pub/issues/2222
    tmpDir = (await Directory.systemTemp.createTemp('dexecve')).path;
    var pubIgnoreRulesFuture = File(p.absolute('.pubignore')).readAsString();
    await gitIgnore.copy(p.join(tmpDir, '.gitignore'));
    await gitIgnore.writeAsString(
      '\n${(await pubIgnoreRulesFuture)}',
      mode: FileMode.append,
    );

    if (dryRun) {
      await dexeca('pub', ['publish', '--dry-run'],
          runInShell: Platform.isWindows);
      return;
    }

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      throw 'accessToken & refreshToken must be supplied!';
    }

    // on windows the path is actually %%UserProfile%%\AppData\Roaming\Pub\Cache
    // not that this really matters because we only intend on running this inside
    // a pipeline which will be running linux.
    var credsFilePath = p.join(_homeDir(), '.pub-cache', 'credentials.json');

    await File(credsFilePath).writeAsString(jsonEncode({
      'accessToken': '${accessToken}',
      'refreshToken': '${refreshToken}',
      'tokenEndpoint': 'https://accounts.google.com/o/oauth2/token',
      'scopes': ['openid', 'https://www.googleapis.com/auth/userinfo.email'],
      'expiration': oAuthExpiration,
    }));

    await dexeca('pub', ['publish', '--force'], runInShell: Platform.isWindows);
  } finally {
    if (tmpDir != null) {
      if (await File(p.join(tmpDir, '.gitignore')).exists()) {
        await File(p.join(tmpDir, '.gitignore')).copy(gitIgnore.path);
      }
      await Directory(tmpDir).delete(recursive: true);
    }
  }
}

String _homeDir() {
  if (Platform.isWindows) return Platform.environment['UserProfile'];
  return Platform.environment['HOME'];
}

Future<void> _searchReplaceVersion(File file, String nextVersion) async {
  var src = await file.readAsString();
  var newSrc = src.replaceAll(
    RegExp(r'version: ".*"'),
    'version: "${nextVersion}"',
  );
  await file.writeAsString(newSrc);
}
