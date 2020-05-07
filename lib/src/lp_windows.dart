import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:dexeca/src/executeable.dart';
import 'package:dexeca/src/executable_not_found_exception.dart';

// ported from: // https://golang.org/src/os/exec/lp_windows.go
// plus some support for hashbang's on windows, for a strict result
// set `hashBang` to false.

List<String> _splitList(String path) {
  if (path?.isEmpty ?? true) {
    return [];
  }
  return path.split(';');
}

bool _chkStat(String file) {
  var fStat = File(file).statSync();
  return fStat.type == FileSystemEntityType.file;
}

bool _hasExt(String file) {
  return p.extension(file).isNotEmpty;
}

Executable _checkForHashBang(String file) {
  try {
    var line = LineSplitter.split(
      utf8.decode(
        File(file).openSync(mode: FileMode.read).readSync(150),
      ),
    ).first;
    line = line.replaceFirst('#!', '');
    line = line.replaceFirst('/usr/bin/env', '').trim();
    var runner = lpWindows(line, hashBang: false);
    return Executable(file.toLowerCase(), runner.file.toLowerCase());
  } on FileSystemException catch (e) {
    if (e.message != 'Cannot open file') {
      rethrow;
    }
  }

  return null;
}

Executable _findExecutable(
  String file,
  List<String> exts,
  bool hashBang,
) {
  if (exts?.isEmpty ?? true) {
    if (_chkStat(file)) {
      return Executable(file.toLowerCase());
    }
    return null;
  }

  if (_hasExt(file)) {
    if (_chkStat(file)) {
      return Executable(file);
    }
  } else if (hashBang) {
    var exe = _checkForHashBang(file);
    if (exe != null) {
      return exe;
    }
  }

  for (var ext in exts) {
    var f = file + ext;
    if (_chkStat(f)) {
      return Executable(f.toLowerCase());
    }
  }

  return null;
}

List<String> _getExts() {
  var exts = <String>[];

  if (Platform.environment.keys.contains('PATHEXT')) {
    if (Platform.environment['PATHEXT'].isNotEmpty) {
      for (var e in Platform.environment['PATHEXT'].toLowerCase().split(';')) {
        if (e?.isEmpty ?? true) continue;
        e = !e.startsWith('.') ? '.${e}' : e;
        exts.add(e);
      }
    }
  }

  if (exts.isEmpty) {
    exts.addAll(['.com', '.exe', '.bat', '.cmd']);
  }

  return exts;
}

Executable lpWindows(String file, {bool hashBang = true}) {
  var exts = _getExts();

  if (p.isAbsolute(file)) {
    var f = _findExecutable(file, exts, hashBang);
    if (f != null) {
      return f;
    }
    throw ExecutableFileNotFoundException(file, [file]);
  }

  var f = _findExecutable(p.join('.', file), exts, hashBang);
  if (f != null) {
    return f;
  }

  var paths = _splitList(Platform.environment['PATH']);
  for (var dir in paths) {
    var f = _findExecutable(p.join(dir, file), exts, hashBang);
    if (f != null) {
      return f;
    }
  }

  throw ExecutableFileNotFoundException(file, paths);
}
