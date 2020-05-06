import 'package:dexeca/src/process_result.dart';

class ProcessResultException implements Exception, ProcessResult {
  final ProcessResult _result;

  @override
  String get combinedOutput => _result.combinedOutput;

  @override
  bool get killed => _result.killed;

  @override
  int get exitCode => _result.exitCode;

  @override
  String get stdout => _result.stdout;

  @override
  String get stderr => _result.stderr;

  @override
  int get pid => _result.pid;

  const ProcessResultException(this._result);

  @override
  String toString() {
    return 'ProcessResultException (pid: ${pid}, exited: ${exitCode}): ${stderr}';
  }
}
