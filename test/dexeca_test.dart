import 'dart:io';
import 'package:test/test.dart';
import 'package:dexeca/dexeca.dart';
import 'package:dexeca/look_path.dart';

void main() {
  test('dexeca', () async {
    var proc =
        await dexeca('ping', _pingArgs('127.0.0.1'), inheritStdio: false);
    expect(proc.exitCode, equals(0));
    expect(proc.stderr, equals(''));
    expect(proc.stdout, contains('127.0.0.1'));
  });

  test('look_path', () async {
    expect(lookPath('ping').file, equals(await _which('ping')));
  });
}

List<String> _pingArgs(String target) {
  if (Platform.isWindows) {
    return [target];
  } else {
    return ['-c', '4', target];
  }
}

Future<String> _which(String file) async {
  if (Platform.isWindows) {
    return (await dexeca(
      'where.exe',
      [file],
      runInShell: false,
      inheritStdio: false,
    ))
        .stdout
        .toLowerCase();
  } else {
    return (await dexeca(
      'which',
      [file],
      runInShell: true,
      inheritStdio: false,
    ))
        .stdout;
  }
}
