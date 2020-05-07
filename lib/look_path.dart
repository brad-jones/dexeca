import 'dart:io';
import 'package:dexeca/src/executeable.dart';
import 'package:dexeca/src/lp_unix.dart';
import 'package:dexeca/src/lp_windows.dart';

Executable lookPath(String file, {bool winHashBang = true}) {
  if (Platform.isWindows) {
    return lpWindows(file, hashBang: winHashBang);
  }
  return lpUnix(file);
}
