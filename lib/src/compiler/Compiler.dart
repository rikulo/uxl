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

    _writeln("\n$_pre/** $desc */");
    _outBeginTempl(name, args, elem.lineNumber);

    _indent();
    for (final node in elem.nodes)
      _do(node);
    _undent();

    _outEndTempl();
    _endTemplate();
  }
  void _outBeginTempl(String name, String args, int lineNumber) {
    _writeln('''
${_pre}List<View> $name({View parent$args}) { //$lineNumber#
$_pre  List<View> ${_current.listVar} = new List(); View _this_;''');
  }
  void _outEndTempl() {
    _writeln("$_pre  return ${_current.listVar};\n$_pre}");
  }

  /** Handles the instantiation of a template.
   *
   *    Template(parent: parent, attr: val)..dataAttributes[attr] = val;
   */
  void _newTempalte(Node node, String name, Map<String, String> attrs) {
    final vi = _current.startView(), viewVar = vi.name, parentVar = vi.parent;
    _write('''
\n$_pre//${node.lineNumber}# ${_toTagComment(name, attrs)}
${_pre}final $viewVar = $name(parent: ${parentVar!=null?parentVar:'parent'}''');

    for (final attr in attrs.keys) {
      if (attr != "forEach" && attr != "if") {
        bool error = false;
        switch (attr) { //check if allowed in template
          case "control":
          case "layout":
          case "profile":
          case "style":
          case "class":
            error = true;
            break;
          default:
            error = attr.startsWith("data-") || attr.startsWith("on.");
            break;
        }

        if (error)
          _warning("${node.lineNumber}: Template doesn't support $attr");
        else
          _write(', $attr: ${_unwrap(attrs[attr])}');
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
    final lineInfo = node.lineNumber != null ? "${node.lineNumber}# ": "";
        //Note: Text doesn't have line number

    var control = attrs["control"], ctrlName, ctrlVar, ctrlTempl;
    if (control != null) {
      if ((control = control.trim()).isEmpty) {
        control = null;
        _warning("${node.lineNumber}: The control attribute is empty");
      } else {
        final i = control.indexOf(':');
        if (i >= 0) {
          var s = control.substring(0, i).trim();
          if (_isValidId(s)) {
            ctrlName = s;
            control = control.substring(i + 1).trim();
          }
        }

        ctrlVar = _current.startCtrl();
        ctrlTempl = "${ctrlVar}T";
        _write("\n${_pre}final $ctrlVar = ");
        _write(_isValidId(control) ? "new $control()": control);
        _writeln(";");
        if (ctrlName != null)
          _writeln("final $ctrlName = $ctrlVar;");

        _startTemplate();
        _outBeginTempl(ctrlTempl, "", node.lineNumber);
        _indent();
      }
    }

    var vi = _current.startView(), viewVar = vi.name, parentVar = vi.parent;

    _write("\n$_pre//$lineInfo");
    _write(bText ? _toComment(attrs["text"]): _toTagComment(name, attrs));
    _write("\n${_pre}final $viewVar = ");
    if (!bText) _write("(_this_ = ");
    _write("new $name()");
    if (!bText) _write(")");

    for (final attr in attrs.keys) {
      String val = attrs[attr];
      if (attr.startsWith("data-")) {
        _write('\n$_pre  ..dataAttributes["${attr.substring(5)}"] = ${_unwrap(val)}');
      } else if (attr.startsWith("on.")) { //action
        final action = attr.substring(3);
        if (!_isValidId(action))
          throw new CompileException("${node.lineNumber}: illegal action name, $attr");

        String name;
        final i = val.indexOf('.');
        if (i >= 0) {
          name = val.substring(0, i).trim();
          if (!_isValidId(name))
            throw new CompileException("${node.lineNumber}: illegal action, $val");
          val = val.substring(i + 1);
        }

        if (!_isValidId(val = val.trim()))
          throw new CompileException("${node.lineNumber}: illegal action, $val");

        if (name == null)
          name = _current.lastCtrl;

        _write("\n$_pre  ..on.$action.add((_e){\n$_pre    ");
        if (name != null)
          _write("$name.");
        _writeln("$val(_e);");
        if (name != null)
          _writeln("$_pre    $name.onCommand('$val', _e);");
        _write("$_pre  })");
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
    _outAddChild(viewVar, parentVar);

    for (final n in node.nodes)
      _do(n);
    _current.endView();

    if (control != null) {
      _undent();
      _outEndTempl();
      _endTemplate();

      vi = _current.startView(); viewVar = vi.name; parentVar = vi.parent;

      _writeln('''
$_pre$ctrlVar.template = $ctrlTempl;
${_pre}final $viewVar = $ctrlVar.view = $ctrlTempl()[0];''');
      _outAddChild(viewVar, parentVar);
      _writeln("$_pre$ctrlVar.onRender();");

      _current.endView();
      _current.endCtrl();
    }
  }
  void _outAddChild(String viewVar, String parentVar) {
    if (parentVar != null)
      _writeln("$_pre$parentVar.addChild($viewVar);");
    else
      _writeln('''
${_pre}if (parent != null)
$_pre  parent.addChild($viewVar);
${_pre}${_current.listVar}.add($viewVar);''');
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
          return val.substring(2, len - 1);
      } else { //handle $foo
        final v = val.substring(1);
        if (_isValidId(v))
          return v;
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
  ///A prefix representing this template info (in a stack of template infos)
  final String _idep;
  final Queue<_VarInfo> _vars = new Queue();
  final Queue<String> _ctrls = new Queue();
  final _TemplateInfo prev;
  int _nextId = 0, _nextCtrlId = 0;

  factory _TemplateInfo(_TemplateInfo prev) {
    var idep, listVar;
    if (prev == null) {
      idep = "";
      listVar = "_rv";
    } else {
      idep = prev._idep;
      idep = idep.isEmpty ? "a": idep == "z" ? "A":
        new String.fromCharCodes([idep.charCodeAt(0) + 1]);
        //assume at most 1+26+26 depth
      listVar = "_rv${idep}";
    }
    return new _TemplateInfo._(prev, idep, listVar);
  }
  _TemplateInfo._(this.prev, this._idep, this.listVar);

  _VarInfo startView() {
    final vprev = _vars.isEmpty ? null: _vars.first,
      id = vprev != null ? vprev._nextId++: _nextId++,
      prefix = vprev != null ? "${vprev.name}_": "_v$_idep";
    final vi = new _VarInfo(vprev, "$prefix$id");
    _vars.addFirst(vi);
    return vi;
  }
  void endView() {
    _vars.removeFirst();
  }

  String get lastCtrl
  => _ctrls.isEmpty ? prev != null ? prev.lastCtrl: null: _ctrls.first;

  String startCtrl() {
    final ci = "_c$_idep${_nextCtrlId++}";
    _ctrls.addFirst(ci);
    return ci;
  }
  void endCtrl() {
    _ctrls.removeFirst();
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
bool _isIdLetter(String cc)
=> _isLetter(cc) || _isDigit(cc) || cc == "_" || cc == "\$";
bool _isValidId(String s) {
  for (int i = s.length; --i >= 0;)
    if (!_isIdLetter(s[i]))
      return false;
  return !s.isEmpty;
}
