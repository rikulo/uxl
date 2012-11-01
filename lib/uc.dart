//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Tue, Oct 23, 2012 10:35:48 AM
// Author: tomyeh

library rikulo_uxl_uc;

import 'dart:io';
import 'package:args/args.dart';
import 'package:html5lib/parser.dart' show parse;
import 'package:rikulo_uxl/compiler.dart';

const VERSION = "0.5.0";

/** File information. */
class FileInfo {
  File source, destination;
  Encoding encoding = Encoding.UTF_8;
}

/** The entry point of UXL compiler. Used to implement `bin/uc.dart`.
 */
void main() {
  final fi = new FileInfo();
  if (_parseArgs(fi))
    fi.source.readAsText(fi.encoding)
      .then((text) {
          final out = fi.destination.openOutputStream();
          try {
            new Compiler().compile(parse(text), out, fi.encoding);
          } finally {
            out.close();
          }
        });
}

bool _parseArgs(FileInfo fi) {
  final argParser = new ArgParser()
    ..addOption("encoding", abbr: 'e', help: "Specify character encoding used by source file")
    ..addFlag("help", abbr: 'h', negatable: false, help: "Display this message")
    ..addFlag("version", abbr: 'v', negatable: false, help: "Version information");
  final args = argParser.parse(new Options().arguments);

  final usage = "Usage: uc [<flags>] <uxl-file> [<dart-file>]";
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
      fi.encoding = Encoding.ASCII;
      break;
    case 'utf-8':
      fi.encoding = Encoding.UTF_8;
      break;
    case 'iso-8859-1':
      fi.encoding = Encoding.ISO_8859_1;
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

  if (!(fi.source = new File(args.rest[0])).existsSync()) {
    print("File not found: ${args.rest[0]}");
    return false;
  }
  if (args.rest.length > 1) {
    fi.destination = new File(args.rest[1]);
    if (args.rest[0] == args.rest[1]) {
      print("Destination can't be the same as the source");
      return false;
    }
  } else {
    val = args.rest[0];
    int i = val.lastIndexOf('.');
    if (i >= 0 && val.indexOf('/', i) >= 0)
      i = -1;
    fi.destination = new File(i >= 0 ? "${val.substring(0, i + 1)}dart": "${val}.dart");
  }
  return true;
}
