import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:dexeca/src/process_result.dart';

typedef _ProcessFutureFactory = Future<ProcessResult> Function();

class Process implements io.Process, Future<ProcessResult> {
  final io.Process _proc;

  @override
  Future<int> get exitCode => _proc.exitCode;

  @override
  Stream<List<int>> get stdout => _proc.stdout;

  @override
  Stream<List<int>> get stderr => _proc.stderr;

  @override
  io.IOSink get stdin => _proc.stdin;

  @override
  int get pid => _proc.pid;

  @override
  bool kill([io.ProcessSignal signal = io.ProcessSignal.sigterm]) {
    _killed = true;
    return _proc.kill(signal);
  }

  bool _killed = false;

  _ProcessFutureFactory _futureFactory;
  Future<ProcessResult> _future;
  Future<ProcessResult> get _futureGetter => _future ??= _futureFactory();

  @override
  Stream<ProcessResult> asStream() => _futureGetter.asStream();

  @override
  Future<ProcessResult> catchError(
    Function onError, {
    bool Function(Object) test,
  }) =>
      _futureGetter.catchError(onError, test: test);

  @override
  Future<S> then<S>(
    FutureOr<S> Function(ProcessResult) onValue, {
    Function onError,
  }) =>
      _futureGetter.then(onValue, onError: onError);

  @override
  Future<ProcessResult> whenComplete(Function() action) =>
      _futureGetter.whenComplete(action);

  @override
  Future<ProcessResult> timeout(Duration timeLimit, {Function() onTimeout}) =>
      _futureGetter.timeout(timeLimit, onTimeout: onTimeout);

  Process(
    this._proc, {
    bool inheritStdio,
    bool captureOutput,
    bool combineOutput,
  }) {
    _futureFactory = () async {
      var combinedBuffer = StringBuffer();
      var stdoutBuffer = StringBuffer();
      var stderrBuffer = StringBuffer();

      if (captureOutput || inheritStdio) {
        await Future.wait([
          () async {
            try {
              await for (var line
                  in stdout.transform(utf8.decoder).transform(LineSplitter())) {
                if (inheritStdio) io.stdout.writeln(line);
                if (captureOutput) {
                  if (combineOutput) {
                    combinedBuffer.writeln(line);
                  } else {
                    stdoutBuffer.writeln(line);
                  }
                }
              }
            } on StateError catch (e) {
              if (e.message != 'Stream has already been listened to.') {
                rethrow;
              }
            }
          }(),
          () async {
            try {
              await for (var line
                  in stderr.transform(utf8.decoder).transform(LineSplitter())) {
                if (inheritStdio) io.stderr.writeln(line);
                if (captureOutput) {
                  if (combineOutput) {
                    combinedBuffer.writeln(line);
                  } else {
                    stderrBuffer.writeln(line);
                  }
                }
              }
            } on StateError catch (e) {
              if (e.message != 'Stream has already been listened to.') {
                rethrow;
              }
            }
          }(),
        ]);
      }

      var exitCode = await _proc.exitCode;
      if (exitCode != 0) {
        throw ProcessResult(
          io.ProcessResult(
            _proc.pid,
            exitCode,
            stdoutBuffer.toString(),
            stderrBuffer.toString(),
          ),
          combinedBuffer.toString(),
          _killed,
        );
      }

      return ProcessResult(
        io.ProcessResult(
          _proc.pid,
          exitCode,
          stdoutBuffer.toString(),
          stderrBuffer.toString(),
        ),
        combinedBuffer.toString(),
        _killed,
      );
    };
  }
}
