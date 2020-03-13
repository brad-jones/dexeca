import 'package:test/test.dart';
import 'package:dexeca/dexeca.dart';

void main() {
  test('dexeca', () async {
    var proc = await dexeca('ping', ['1.1.1.1'], inheritStdio: false);
    expect(proc.exitCode, equals(0));
    expect(proc.stderr, equals(''));
    expect(proc.stdout, contains('1.1.1.1'));
  });
}
