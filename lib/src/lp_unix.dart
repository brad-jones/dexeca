import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:dexeca/src/executeable.dart';
import 'package:dexeca/src/executable_not_found_exception.dart';

// ported from: https://golang.org/src/os/exec/lp_unix.go

List<String> _splitList(String path) {
  if (path?.isEmpty ?? true) {
    return [];
  }
  return path.split(':');
}

bool _isExecutable(String file) {
  var fStat = File(file).statSync();
  if (fStat.type == FileSystemEntityType.file) {
    if (fStat.mode & 0111 != 0) {
      return true;
    }
  }
  return false;
}

Executable lpUnix(String file) {
  if (file.contains('/')) {
    if (_isExecutable(file)) {
      return Executable(file);
    }
    throw ExecutableFileNotFoundException(file, [file]);
  }

  var paths = _splitList(Platform.environment['PATH']);
  for (var dir in paths) {
    if (dir?.isEmpty ?? true) {
      dir = '.';
    }
    var path = p.join(dir, file);
    if (_isExecutable(path)) {
      return Executable(path);
    }
  }

  throw ExecutableFileNotFoundException(file, paths);
}
