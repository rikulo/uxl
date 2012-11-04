//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Oct 23, 2012 10:35:48 AM
// Author: tomyeh

library rikulo_uxl_uc;

import 'dart:io';
import 'package:args/args.dart';
import 'package:html5lib/parser.dart' show HtmlParser;
import 'package:rikulo_uxl/compile.dart' show compile;

const VERSION = "0.5.0";

class Environ {
  Encoding encoding = Encoding.UTF_8;
  bool verbose = false;
  List<String> sources;
}

/** The entry point of UXL compiler. Used to implement `bin/uc.dart`.
 */
void main() {
  final env = new Environ();
  if (!_parseArgs(env))
    return;

  for (var name in env.sources) {
    final source = new File(name);
    if (!source.existsSync()) {
      print("File not found: ${name}");
      return;
    }

    int i = name.lastIndexOf('.');
    if (i >= 0 && name.indexOf('/', i) >= 0)
      i = -1;
    final dest = new File(i >= 0 ? "${name.substring(0, i + 1)}dart": "${name}.dart");

    if (env.verbose) {
      int i = dest.name.lastIndexOf('/') + 1;
      print("Compile ${source.name} to ${i > 0 ? dest.name.substring(i): dest.name}");
    }
    source.readAsText(env.encoding)
      .then((text) {
          final out = dest.openOutputStream();
          try {
            compile(
              new HtmlParser(text, lowercaseElementName: false,
                lowercaseAttrName: false, encoding: env.encoding.name)
                .parseFragment(),
              out, env.encoding);
          } finally {
            out.close();
          }
        });
  }
}

bool _parseArgs(Environ env) {
  final argParser = new ArgParser()
    ..addOption("encoding", abbr: 'e', help: "Specify character encoding used by source file")
    ..addFlag("help", abbr: 'h', negatable: false, help: "Display this message")
    ..addFlag("verbose", abbr: 'v', negatable: false, help: "Enable verbose output")
    ..addFlag("version", negatable: false, help: "Version information");
  final args = argParser.parse(new Options().arguments);

  final usage = "Usage: uc [<flags>] <uxl-file> [<uxl-file>...]";
  if (args['version']) {
    print("UXL Compiler version $VERSION");
    return false;
  }
  if (args['help']) {
    print(usage);
    print("\nCompiles the UXL file to a Dart file.\n\nOptions:");
    print(argParser.getUsage());
    return false;
  }

  String val = args['encoding'];
  if (val != null)
  switch (val.toLowerCase()) {
    case 'ascii':
      env.encoding = Encoding.ASCII;
      break;
    case 'utf-8':
      env.encoding = Encoding.UTF_8;
      break;
    case 'iso-8859-1':
      env.encoding = Encoding.ISO_8859_1;
      break;
    default:
      print("Unknown encoding: $val");
      return false;
  }

  if (args.rest.isEmpty) {
    print(usage);
    print("Use -h for a list of possible options.");
    return false;
  }

  env.verbose = args['verbose'];
  env.sources = args.rest;
  return true;
}
