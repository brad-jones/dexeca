class ExecutableFileNotFoundException implements Exception {
  final String file;

  final List<String> path;

  const ExecutableFileNotFoundException(this.file, this.path);

  @override
  String toString() {
    return 'ExecutableFileNotFoundException: An executable file named `${file}` was not found in \$PATH';
  }
}
