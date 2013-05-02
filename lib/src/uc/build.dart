//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:53:53 PM
// Author: tomyeh
part of rikulo_uc;

/** Compiles the given [source] UXL document to the given output stream [out].
 * Notice that the caller has to close the output stream by himself.
 */
void compile(Document source, IOSink out, {
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
  
  if (new Path(source.path).canonicalize().toNativePath() ==
      new Path(dest.path).canonicalize().toNativePath()) {
    print("Source and destination are the same file, $source");
    return;
  }

  if (verbose) {
    final int i = dest.path.lastIndexOf('/') + 1;
    print("Compile ${source.path} to ${i > 0 ? dest.path.substring(i) : dest.path}");
  }
  
  source.readAsString(encoding: encoding).then((text) {
    final out = dest.openWrite(encoding: encoding);
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
void build(List<String> arguments, {String filenameMapper(String source),
    Encoding encoding: Encoding.UTF_8}) {
  final ArgParser argParser = new ArgParser()
    ..addOption("changed", allowMultiple: true)
    ..addOption("removed", allowMultiple: true)
    ..addFlag("clean", negatable: false)
    ..addFlag("machine", negatable: false)
    ..addFlag("full", negatable: false);
  
  final ArgResults args = argParser.parse(arguments);
  final List<String> changed = args["changed"];
  final List<String> removed = args["removed"];
  final bool clean = args["clean"];
  
  if (clean) { // clean only
    Directory.current.list(recursive: true).listen((fse) {
      if (fse is File && fse.path.endsWith(".uxl.dart"))
        fse.delete();
    });

  } else if (removed.isEmpty && changed.isEmpty) { // full build
    Directory.current.list(recursive: true).listen((fse) {
      if (fse is File && fse.path.endsWith(".uxl.xml"))
        compileFile(fse.path, encoding: encoding,
          destinationName: filenameMapper != null ? filenameMapper(fse.path): null);
    });
    
  } else {
    for (String name in removed) {
      if (name.endsWith(".uxl.xml")) {
        final File gen = new File("${name.substring(0, name.length - 4)}.dart");
        if (gen.existsSync())
          gen.delete();
      }
    }
    for (String name in changed)
      if (name.endsWith(".uxl.xml"))
        compileFile(name, encoding: encoding,
          destinationName: filenameMapper != null ? filenameMapper(name): null);
  }
}
