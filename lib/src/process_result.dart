import 'dart:io' as io;

class ProcessResult implements io.ProcessResult {
  final io.ProcessResult _procResult;

  final String combinedOutput;

  final bool killed;

  @override
  int get exitCode => _procResult.exitCode;

  @override
  String get stdout => _procResult.stdout as String;

  @override
  String get stderr => _procResult.stderr as String;

  @override
  int get pid => _procResult.pid;

  ProcessResult(this._procResult, this.combinedOutput, this.killed);
}
