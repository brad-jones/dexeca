import 'dart:cli';
import 'dart:io' as io;
import 'package:dexeca/look_path.dart';
import 'package:dexeca/src/process.dart';
export 'package:dexeca/src/process.dart';
export 'package:dexeca/src/process_result.dart';
import 'package:dexeca/src/process_result_exception.dart';

/// This function will return an object which looks like a normal
/// `dart:io.Process` object as well as being awaitable, where the awaited
/// result looks like `dart:io.ProcessResult`.
Process dexeca(
  String exe,
  List<String> args, {
  String prefix,
  String prefixSeperator = ' | ',
  String workingDirectory,
  Map<String, String> environment,
  bool inheritStdio = true,
  bool captureOutput = true,
  bool combineOutput = false,
  bool includeParentEnvironment = true,
  bool runInShell = false,
  bool winHashBang = true,
  io.ProcessStartMode mode = io.ProcessStartMode.normal,
}) {
  if (!runInShell) {
    var executable = lookPath(exe, winHashBang: winHashBang);
    if (executable.runner?.isNotEmpty ?? false) {
      args.insert(0, executable.file);
      exe = executable.runner;
    } else {
      exe = executable.file;
    }
  }

  if (mode == io.ProcessStartMode.inheritStdio) {
    inheritStdio = false;
    captureOutput = false;
  }

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
    prefix: prefix == null ? '' : '${prefix}${prefixSeperator}',
  );
}
