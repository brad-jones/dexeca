import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'package:dexeca/dexeca.dart';

/// Just a helper so that this example will execute as expected everywhere.
List<String> _pingArgs(String target) {
  if (io.Platform.isWindows) {
    return [target];
  } else {
    return ['-c', '4', target];
  }
}

Future<void> main(List<String> args) async {
  // We are not exactly the same as `sindresorhus/execa`. By default dexeca
  // will interleave all STDIO to the parent process, ie: inheritStdio = true.
  // This is the most common case I personally run into all the time.
  var result = await dexeca('ping', _pingArgs('1.1.1.1'));

  // By default after the command has executed
  // you can also access the captured output.
  print(result.stdout);
  print(result.stderr);

  // Don't want to stream the STDIO but still want to capture the output
  var result2 = await dexeca('ping', _pingArgs('1.0.0.1'), inheritStdio: false);
  print(result2.stdout);
  print(result2.stderr);

  // Want to capture combined output?
  var result3 = await dexeca(
    'ping',
    _pingArgs('8.8.8.8'),
    inheritStdio: false,
    combineOutput: true,
  );
  print(result3.combinedOutput);
  print(result3.stdout.isEmpty);
  print(result3.stderr.isEmpty);

  // Got your own stream that you want the output written to?
  // Keep in mind if you listen to the process's stdout or stderr then
  // `dexeca` cannot as such `inheritStdio`, `captureOutput` & `captureOutput`
  // are meaningless.
  var customStdOut = StreamController<List<int>>();
  var proc1 = dexeca('ping', _pingArgs('8.8.4.4'));
  var pipe1 = proc1.stdout.pipe(customStdOut);
  await for (var x in customStdOut.stream
      .transform(utf8.decoder)
      .transform(LineSplitter())) {
    print(x);
  }
  await pipe1;
  await proc1;

  // Redirect output to a file
  var proc2 = dexeca('ping', _pingArgs('www.ford.com'));
  await proc2.stdout.pipe(File('./fordping-results.txt').openWrite());
  await proc2;

  // Handling errors - dexeca will throw a ProcessResult (instead of returning
  // one) when ever a command exits with a non 0 code.
  try {
    var procResultIfSuccess = await dexeca('ping', _pingArgs('a.b.c.d'));
    print(procResultIfSuccess.exitCode); // should always be 0
  } on ProcessResult catch (procResultIfFailure) {
    print(procResultIfFailure.exitCode); // could be anything but 0
  }

  // Cancelling a spawned process
  var proc4 = dexeca('ping', _pingArgs('pub.dev'));
  Future.delayed(Duration(seconds: 2), () {
    proc4.kill();
  });
  try {
    await proc4;
  } on ProcessResult catch (e) {
    print(e.killed);
  }

  // Run many commands at once with interleaved output
  await Future.wait([
    dexeca('ping', _pingArgs('www.facebook.com')),
    dexeca('ping', _pingArgs('www.google.com')),
  ]);
}
