//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:56:10 PM
// Author: tomyeh

/**
 * The UXL compiler.
 */
class _Compiler {
  final Document _source;
  final OutputStream _out;
  final Encoding _encoding;
  _Context _ctx;
  final List<_Context> _ctxes = new List();

  _Compiler(this._source, this._out, [Encoding this._encoding=Encoding.UTF_8]);

  void compile() {
    for (final node in _source.nodes)
      _dump(node, "");
  }
  void _dump(Node node, String prefix) {
    print("$prefix${node.runtimeType}: ${node is ProcessingInstruction?node.target:node is Element?node.tagName:""}");
    if (node is Element)
      for (final k in node.attributes.keys)
        print('$prefix$k="${node.attributes[k]}"');
    for (final n in node.nodes)
      _dump(n, "$prefix  ");
  }
}

class _Context {
  String prefix;
}