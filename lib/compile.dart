//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:53:53 PM
// Author: tomyeh

library rikulo_uxl_compile;

import 'dart:io';
import 'package:args/args.dart';
import 'package:html5plus/dom.dart';
import 'package:html5plus/parser.dart' show HtmlParser;

part "src/compiler/Compiler.dart";
part "src/compiler/Util.dart";

/** Compiles the given [source] UXL document to the given output stream [out].
 * Notice that the caller has to close the output stream by himself.
 */
void compile(Document source, OutputStream out, {
String sourceName, Encoding encoding: Encoding.UTF_8, bool verbose: false}) {
  new Compiler(source, out, sourceName: sourceName, encoding: encoding, verbose: verbose).compile();
}

/** Compiles the UXL document of the given [sourceName] and write the result to
 * the file of given [destinationName].
 */
void compileFile(String sourceName, {String destinationName, bool verbose : false, 
Encoding encoding : Encoding.UTF_8}) {
  
  final source = new File(sourceName);
  if (!source.existsSync()) {
    print("File not found: ${sourceName}");
    return;
  }
  
  if (destinationName == null) {
    final int i = sourceName.lastIndexOf('.');
    final int j = sourceName.lastIndexOf('/');
    destinationName = i >= 0 && j < i ? "${sourceName.substring(0, i + 1)}dart" : "${sourceName}.dart";
  }
  final dest = new File(destinationName);
  
  if (verbose) {
    final int i = dest.name.lastIndexOf('/') + 1;
    print("Compile ${source.name} to ${i > 0 ? dest.name.substring(i) : dest.name}");
  }
  
  source.readAsString(encoding).then((text) {
    final out = dest.openOutputStream();
    try {
      compile(
          new HtmlParser(text, encoding: encoding.name, lowercaseElementName: false, 
              lowercaseAttrName: false, cdataOK: true).parseFragment(),
          out, sourceName: sourceName, encoding: encoding, verbose: verbose);
    } finally {
      out.close();
    }
  });
  
}

/** Compile changed UXL files. This method shall be called within build.dart,
 * with new Options().arguments as its [arguments].
 */
void build(List<String> arguments) {
  final ArgParser argParser = new ArgParser()
    ..addOption("changed", allowMultiple: true)
    ..addOption("removed", allowMultiple: true)
    ..addFlag("clean", negatable: false)
    ..addFlag("machine", negatable: false);
  
  final ArgResults args = argParser.parse(arguments);
  final List<String> changed = args["changed"];
  final List<String> removed = args["removed"];
  final bool clean = args["clean"];
  
  if (clean) { // clean only
    new Directory.current().list(recursive: true).onFile = (String name) {
      if (name.endsWith(".uxl.dart"))
        new File(name).delete();
    };
    
  } else if (removed.isEmpty && changed.isEmpty) { // full build
    new Directory.current().list(recursive: true).onFile = (String name) {
      if (name.endsWith(".uxl.xml") || name.endsWith(".uxl"))
        compileFile(name);
    };
    
  } else {
    for (String name in removed) {
      final bool uxlxml = name.endsWith(".uxl.xml");
      if (uxlxml || name.endsWith(".uxl")) {
        final File gen = new File("${uxlxml ? name.substring(0, name.length - 4) : name}.dart");
        if (gen.existsSync())
          gen.delete();
      }
    }
    for (String name in changed)
      if (name.endsWith(".uxl.xml") || name.endsWith(".uxl"))
        compileFile(name);
  }
  
}
