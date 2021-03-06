//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Jan 16, 2013 10:16:35 AM
// Author: tomyeh
part of rikulo_uc;

class _Environ {
  Encoding encoding = UTF8;
  bool verbose = false;
  List<String> sources;
}

/** The entry point of UXL compiler. Used to implement `bin/uc.dart`.
 */
void main(List<String> arguments) {
  final env = new _Environ();
  if (!_parseArgs(arguments, env))
    return;

  for (var name in env.sources)
    compileFile(name, encoding: env.encoding, verbose: env.verbose);
}

bool _parseArgs(List<String> arguments, _Environ env) {
  final argParser = new ArgParser()
    ..addOption("encoding", abbr: 'e',
      help: "Specify character encoding used by source file, such as utf-8, latin-1, ascii")
    ..addFlag("help", abbr: 'h', negatable: false, help: "Display this message")
    ..addFlag("verbose", abbr: 'v', negatable: false, help: "Enable verbose output")
    ..addFlag("version", negatable: false, help: "Version information");
  final args = argParser.parse(arguments);

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
      env.encoding = ASCII;
      break;
    case 'utf-8':
      env.encoding = UTF8;
      break;
    case 'iso-8859-1':
    case 'latin-1':
      env.encoding = LATIN1;
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
