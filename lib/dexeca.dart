import 'dart:cli';
import 'dart:io' as io;
import 'package:dexeca/src/process.dart';
export 'package:dexeca/src/process.dart';
export 'package:dexeca/src/process_result.dart';

Process dexeca(
  String exe,
  List<String> args, {
  String workingDirectory,
  Map<String, String> environment,
  bool inheritStdio = true,
  bool captureOutput = true,
  bool combineOutput = false,
  bool includeParentEnvironment = true,
  bool runInShell = false,
  io.ProcessStartMode mode = io.ProcessStartMode.normal,
}) {
  return Process(
    waitFor(io.Process.start(
      exe,
      args,
      workingDirectory: workingDirectory,
      environment: environment,
      includeParentEnvironment: includeParentEnvironment,
      runInShell: runInShell,
      mode: mode,
    )),
    captureOutput: captureOutput,
    combineOutput: combineOutput,
    inheritStdio: inheritStdio,
  );
}
