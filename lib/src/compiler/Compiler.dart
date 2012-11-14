//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:56:10 PM
// Author: tomyeh
part of rikulo_uxl_compile;

/**
 * The UXL compiler.
 */
class Compiler {
  final Document source;
  final OutputStream destination;
  final Encoding encoding;
  final bool verbose;
  _TemplateInfo _current;
  //used for indent
  String _pre = "";
  final Queue<_TemplateInfo> _tmplInfos = new Queue();
  //declared template names
  final Set<String> _tmplDecls = new Set();
  //defined template names
  final Set<String> _tmplDefs = new Set();

  Compiler(this.source, this.destination, {Encoding this.encoding:Encoding.UTF_8,
    bool this.verbose: false});

  void compile() {
    //scan first, so user doesn't have to declare templates before use
    for (final node in source.nodes)
      _scan(node, true);

    for (final node in source.nodes)
      _do(node);
  }

  void _scan(Node node, bool topmost) {
    if (node is Element) {
      Element elem = node;
      if (elem.tagName == "Template")
        _tmplDecls.add(_requiredAttr(elem, "name"));
      else if (topmost)
        throw new CompileException("${elem.lineNumber}: The root element must be <Template>.");
    } else if (node is ProcessingInstruction) {
      ProcessingInstruction pi = node;
      if (pi.target == "template" && !pi.data.isEmpty)
        for (String nm in pi.data.split(' '))
          _tmplDecls.add(nm);
    }

    for (final n in node.nodes)
      _scan(n, false);
  }

  void _do(Node node) {
    if (node is Element) {
      _doElement(node);
    } else if (node is ProcessingInstruction) {
      _doPI(node);
    } else if (node is Text) {
      final text = node.text.trim();
      if (!text.isEmpty)
        _newText(node, text);
    }
  }
  void _doElement(Element elem) {
    final name = elem.tagName;
    if (name == "Template") {
      _defineTemplate(elem);
      return;
    }

    final attrs = elem.attributes;
    var forEach = attrs["forEach"];
    if (forEach != null) {
      if (forEach.isEmpty) {
        forEach = null;
        _warning("${elem.lineNumber}: The forEach attribute is empty");
      } else {
        _writeln("\n${_pre}for (var $forEach) {");
        _indent();
      }
    }

    var ifc = attrs["if"];
    if (ifc != null) {
      if (ifc.isEmpty) {
        ifc = null;
        _warning("${elem.lineNumber}: The if attribute is empty");
      } else {
        _writeln("\n${_pre}if ($ifc) {");
        _indent();
      }
    }

    if (name == "Apply") {
      _doApply(elem.nodes);
      _checkAttrs(elem, _applyAllowed);
    } else if (_tmplDecls.contains(name)) {
      _newTempalte(elem, name, attrs);
      if (!elem.nodes.isEmpty)
        _warning("${elem.lineNumber}: $name is a template. It can't have child elements.");
    } else {
      _newView(elem, name, attrs);
    }

    if (ifc != null)
      _writeln("${_undent()}}");
    if (forEach != null)
      _writeln("${_undent()}}");
  }

  ///Handles processing instructions
  void _doPI(ProcessingInstruction pi) {
    switch (pi.target) {
      case "dart":
        _writeln("\n//${pi.lineNumber}#");
        _writeln(pi.data);
        break;
      case "template":
        break; //handled by _scan
      default:
        _warning("${pi.lineNumber}: Unknown <? ${pi.target} ?>");
    }
  }

  //Handles the definition of a template
  void _defineTemplate(Element elem) {
    _startTemplate();

    final name = _requiredAttr(elem, "name");
    if (_tmplDefs.contains(name))
      throw new CompileException("${elem.lineNumber}: Duplicated template definition, $name");
    _tmplDefs.add(name);
    if (verbose)
      print("Generate template $name...");

    var desc = elem.attributes["description"],
      args = elem.attributes["args"];
    if (desc == null)
      desc = "Template, $name, for creating views.";
    args = args != null && !args.trim().isEmpty ? ", $args": "";
    _checkAttrs(elem, _templAllowed);
    _writeln('''
\n$_pre/** $desc */
${_pre}List<View> $name({View parent$args}) { //${elem.lineNumber}#
$_pre  List<View> ${_current.listVar} = new List();
$_pre  View _this_;''');

    _indent();
    for (final node in elem.nodes)
      _do(node);
    _undent();

    _writeln("$_pre  return ${_current.listVar};\n$_pre}");
    _endTemplate();
  }

  /** Handles the instantiation of a template.
   *
   *    Template(parent: parent, attr: val)..dataAttributes[attr] = val;
   */
  void _newTempalte(Node node, String name, Map<String, String> attrs) {
    final vi = _current.startView(),
      viewVar = vi.name, parentVar = vi.parent;
    _write('''
\n$_pre//${node.lineNumber}# ${_toTagComment(name, attrs)}
${_pre}final $viewVar = $name(parent: ${parentVar!=null?parentVar:'parent'}''');

    for (final attr in attrs.keys) {
      if (attr.startsWith("data-")) {
        _warning("${node.lineNumber}: Data attributes, $attr, not allowed in a template, $name");
      } else {
        final val = attrs[attr];
        switch (attr) {
        case "forEach": case "if":
          break; //ignore
        case "control": //not allowed in template
        case "layout":
        case "profile":
        case "style":
        case "class":
          _warning("${node.lineNumber}: Template doesn't support $attr");
          break;
        default:
          _write(', $attr: ${_unwrap(val)}');
          break;
        }
      }
    }

    _writeln(");");
    if (parentVar == null)
      _writeln("${_pre}${_current.listVar}.addAll($viewVar);");

    _current.endView();
  }
  /** Handles the instantiation of a view.
   *
   *    new View()..attr = val..dataAttributes[attr] = val;
   */
  void _newView(Node node, String name, Map<String, String> attrs, [bool bText=false]) {
    final vi = _current.startView(),
      viewVar = vi.name, parentVar = vi.parent,
      lineInfo = node.lineNumber != null ? "${node.lineNumber}# ": "";
        //Text doesn't have line number

    _write("\n$_pre//$lineInfo");
    _write(bText ? _toComment(attrs["text"]): _toTagComment(name, attrs));
    _write("\n${_pre}final $viewVar = ");
    if (!bText) _write("(_this_ = ");
    _write("new $name()");
    if (!bText) _write(")");

    for (final attr in attrs.keys) {
      final val = attrs[attr];
      if (attr.startsWith("data-")) {
        _write('\n$_pre  ..dataAttributes["${attr.substring(5)}"] = ${_unwrap(val)}');
      } else {
        switch (attr) {
        case "forEach": case "if": case "control":
          break; //ignore
        case "layout":
        case "profile":
          _write('\n$_pre  ..$attr.text = ${_unwrap(val)}');
          break;
        case "style":
          _write('\n$_pre  ..$attr.cssText = ${_unwrap(val)}');
          break;
        case "class":
          for (final css in val.split(" "))
            _write('\n$_pre  ..classes.add("$css")');
          break;
        default:
        //Note: to really handle it well, we have to detect if a field is text.
        //However, it depends on mirrors and UXL files might be compiled before
        //other dart files are ready. It is better to leave it to the users:
        //${foo.toString()} (if they have to convert it)
          _write("\n$_pre  ..$attr = ");
          _write(bText ? "'''$val'''": "${_unwrap(val)}");
          break;
        }
      }
    }
    _writeln(";");

    if (parentVar != null)
      _writeln("$_pre$parentVar.addChild($viewVar);");
    else
      _writeln('''
${_pre}if (parent != null)
$_pre  parent.addChild($viewVar);
${_pre}${_current.listVar}.add($viewVar);''');

    for (final n in node.nodes)
      _do(n);

    final control = attrs["control"];
    if (control != null) {
      if (control.isEmpty) {
        _warning("${node.lineNumber}: The control attribute is empty");
      } else {
        _writeln("${_pre}($control)($viewVar);");
      }
    }

    _current.endView();
  }

  //Handle Text
  void _newText(Node node, String text) {
    _newView(node, "TextView", {"text": text}, true);
  }

  //Handle Apply
  void _doApply(List<Node> children) {
    for (final node in children)
      _do(node);
  }

  //Utilities//
  String _requiredAttr(Element elem, String attr) {
    final val = elem.attributes[attr];
    if (val == null || val.isEmpty)
      throw new CompileException("${elem.lineNumber}: The $attr attribute is required");
    return val;
  }
  void _checkAttrs(Element elem, Set<String> allowedAttrs) {
    for (final attr in elem.attributes.keys)
      if (!allowedAttrs.contains(attr))
        _warning("${elem.lineNumber}: The $attr attribute not allowed in ${elem.tagName}");
  }

  _indent() => _pre = "$_pre  ";
  _undent() => _pre = _pre.substring(0, _pre.length - 2);

  static final Set<String> _templAllowed =
    new Set.from(const ["name", "args", "description"]);
  static final Set<String> _applyAllowed =
    new Set.from(const ["if", "forEach"]);

  ///Generates the attribute value.
  ///We have to *unwrap* $ if necessary to avoid the string conversion
  String _unwrap(String val) {
    if (val.length > 1 && val[0] == "\$") { //handle ${}
      var cc = val[1],
        len = val.length;
      if (cc == '{') {
        if (val[len - 1] == '}' && val.indexOf("\${", 2) < 0)
          return val.substring(2, len -1);
      } else { //handle $foo
        for (int i = 1;;) {
          if (i >= len)
            return val.substring(1, len);
          cc = val[i++];
          if (!_isLetter(cc) && !_isDigit(cc) && cc != "_" && cc != "\$")
            break;
        }
      }
    }
    return "'''$val'''";
  }

  void _write(String str) {
    destination.writeString(str, encoding);
  }
  void _writeln([String str]) {
    if (str != null)
      _write(str);
    _write("\n");
  }
  String _toTagComment(String name, Map<String, String> attrs)  {
    final StringBuffer sb = new StringBuffer("<").add(name);
    for (final attr in attrs.keys) {
      final val = attrs[attr].replaceAll("\n", "\\n");
      sb.add(' $attr="${val}"');
      if (sb.length > 40)
        return "${sb.toString().substring(0, 36).trim()}...>";
    }
    return "$sb>";
  }
  String _toComment(String text) {
    text = text.replaceAll("\n", "\\n");
    return text.length > 30 ? "${text.substring(0, 27)}...": text;
  }

  //parentVar is null => a new template
  //parentVar is not null => a new indent (for child views)
  void _startTemplate() {
    _tmplInfos.addFirst(_current = new _TemplateInfo(_current));
  }
  void _endTemplate() {
    _tmplInfos.removeFirst();
    _current = _tmplInfos.isEmpty ? null: _tmplInfos.first;
  }
}

class _VarInfo {
  final String name;
  final String parent;
  int _nextId = 0;

  _VarInfo(_VarInfo prev, this.name): parent = prev != null ? prev.name: null;
}
class _TemplateInfo {
  ///Variable name referencing to the return list
  final listVar;
  ///An ID represents the depth of this template info
  final String depth;
  final Queue<VarInfo> varInfos = new Queue();
  int _nextId = 0;

  factory _TemplateInfo(_TemplateInfo prev) {
    var depth, listVar;
    if (prev == null) {
      depth = "";
      listVar = "_rv";
    } else {
      depth = prev.depth;
      depth = depth.isEmpty ? "a": depth == "z" ? "A":
        new String.fromCharCodes([depth.charCodeAt(0) + 1]);
        //assume at most 1+26+26 depth
      listVar = "_rv${depth}";
    }
    return new _TemplateInfo._(depth, listVar);
  }
  _TemplateInfo._(this.depth, this.listVar);

  _VarInfo startView() {
    final prev = varInfos.isEmpty ? null: varInfos.first,
      id = prev != null ? prev._nextId++: _nextId++,
      prefix = prev != null ? "${prev.name}_": "_v$depth";
    _VarInfo vi = new _VarInfo(prev, "$prefix$id");
    varInfos.addFirst(vi);
    return vi;
  }
  void endView() {
    varInfos.removeFirst();
  }
}

///show warning messages
void _warning(String msg) {
  print("Warning: $msg");
}

//FUTURE: use rikulo-commons instead
const _ZERO = 48, _LOWER_A = 97, _UPPER_A = 65;

bool _isLetter(String char) {
  if (char == null) return false;
  int cc = char.charCodeAt(0);
  return cc >= _LOWER_A && cc < _LOWER_A + 26 || cc >= _UPPER_A && cc < _UPPER_A + 26;
}
bool _isDigit(String char) {
  if (char == null) return false;
  int cc = char.charCodeAt(0);
  return cc >= _ZERO && cc < _ZERO + 10;
}
