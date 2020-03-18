# dexeca

![Pub Version](https://img.shields.io/pub/v/dexeca)
![.github/workflows/main.yml](https://github.com/brad-jones/dexeca/workflows/.github/workflows/main.yml/badge.svg?branch=master)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![KeepAChangelog](https://img.shields.io/badge/Keep%20A%20Changelog-1.0.0-%23E05735)](https://keepachangelog.com/)
[![License](https://img.shields.io/github/license/brad-jones/dexeca.svg)](https://github.com/brad-jones/dexeca/blob/master/LICENSE)

A dartlang child process executor inspired by <https://github.com/sindresorhus/execa>

## Usage

```dart
import 'package:dexeca/dexeca.dart';

void main() {
  await dexeca('ping', ['1.1.1.1']);
}
```

> see [./example/main.dart](./example/main.dart) for more details
