//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Oct 23, 2012 10:35:48 AM
// Author: tomyeh

library rikulo_uxl_uc;

import 'dart:io';
import 'package:args/args.dart';
import 'package:html5lib/parser.dart' show parse;
import 'package:rikulo_uxl/compiler.dart';

const VERSION = "0.5.0";

Encoding encoding = Encoding.UTF_8;
bool verbose = false;

/** The entry point of UXL compiler. Used to implement `bin/uc.dart`.
 */
void main() {
  final names = _parseArgs();
  if (names == null)
    return;

  for (var name in names) {
    final source = new File(name);
    if (!source.existsSync()) {
      print("File not found: ${name}");
      return null;
    }

    int i = name.lastIndexOf('.');
    if (i >= 0 && name.indexOf('/', i) >= 0)
      i = -1;
    final dest = new File(i >= 0 ? "${name.substring(0, i + 1)}dart": "${name}.dart");

    if (verbose) {
      int i = dest.name.lastIndexOf('/') + 1;
      print("Compile ${source.name} to ${i > 0 ? dest.name.substring(i): dest.name}");
    }
    source.readAsText(encoding)
      .then((text) {
          final out = dest.openOutputStream();
          try {
            new Compiler().compile(parse(text), out, encoding);
          } finally {
            out.close();
          }
        });
  }
}

List<String> _parseArgs() {
  final argParser = new ArgParser()
    ..addOption("encoding", abbr: 'e', help: "Specify character encoding used by source file")
    ..addFlag("help", abbr: 'h', negatable: false, help: "Display this message")
    ..addFlag("verbose", abbr: 'v', negatable: false, help: "Enable verbose output")
    ..addFlag("version", negatable: false, help: "Version information");
  final args = argParser.parse(new Options().arguments);

  final usage = "Usage: uc [<flags>] <uxl-file> [<uxl-file>...]";
  if (args['version']) {
    print("UXL Compiler version $VERSION");
    return null;
  }
  if (args['help']) {
    print(usage);
    print("\nCompiles the UXL file to a Dart file.\n\nOptions:");
    print(argParser.getUsage());
    return null;
  }

  String val = args['encoding'];
  if (val != null)
  switch (val.toLowerCase()) {
    case 'ascii':
      encoding = Encoding.ASCII;
      break;
    case 'utf-8':
      encoding = Encoding.UTF_8;
      break;
    case 'iso-8859-1':
      encoding = Encoding.ISO_8859_1;
      break;
    default:
      print("Unknown encoding: $val");
      return null;
  }

  if (args.rest.isEmpty) {
    print(usage);
    print("Use -h for a list of possible options.");
    return null;
  }

  verbose = args['verbose'];
  return args.rest;
}
