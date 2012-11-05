//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Mon, Nov 05, 2012 12:14:19 PM
// Author: tomyeh
part of rikulo_uxl_compile;

/** A compiling exception.
 */
class CompileException implements Exception {
  final String message;

  const CompileException(String this.message);
  String toString() => "CompileException($message)";
}

