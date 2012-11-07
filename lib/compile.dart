//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:53:53 PM
// Author: tomyeh

library rikulo_uxl_compile;

import 'dart:io';
import 'package:html5lib/dom.dart';

part "src/compiler/Compiler.dart";
part "src/compiler/Util.dart";

/** Compiles the given UXL document to the given output stream.
 * Notice that the caller has to close the output stream by himself.
 */
void compile(Document source, OutputStream out, {Encoding encoding: Encoding.UTF_8,
  bool verbose: false}) {
  new Compiler(source, out, encoding: encoding, verbose: verbose).compile();
}
