import 'dart:io';
import 'package:test/test.dart';
import 'package:dexeca/dexeca.dart';

void main() {
  test('dexeca', () async {
    var proc =
        await dexeca('ping', _pingArgs('127.0.0.1'), inheritStdio: false);
    expect(proc.exitCode, equals(0));
    expect(proc.stderr, equals(''));
    expect(proc.stdout, contains('127.0.0.1'));
  });
}

List<String> _pingArgs(String target) {
  if (Platform.isWindows) {
    return [target];
  } else {
    return ['-c', '4', target];
  }
}
