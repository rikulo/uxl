//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Nov 01, 2012  4:56:10 PM
// Author: tomyeh
part of rikulo_uxl_compile;

/**
 * The UXL compiler.
 */
class Compiler {
  final String sourceName;
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

  Compiler(Document this.source, OutputStream this.destination, {
    String this.sourceName,
    Encoding this.encoding:Encoding.UTF_8,
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
        throw new CompileException("${_loc(elem)}The root element must be <Template>.");
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
        _warning("The forEach attribute is empty", elem);
      } else {
        _writeln("\n${_pre}for (var $forEach) {");
        _indent();
      }
    }

    var ifc = attrs["if"];
    if (ifc != null) {
      if (ifc.isEmpty) {
        ifc = null;
        _warning("The if attribute is empty", elem);
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
        _warning("$name is a template. It can't have child elements.", elem);
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
        _warning("Unknown <? ${pi.target} ?>", pi);
    }
  }

  //Handles the definition of a template
  void _defineTemplate(Element elem) {
    final name = _requiredAttr(elem, "name");
    if (_tmplDefs.contains(name))
      throw new CompileException("${_loc(elem)}Duplicated template definition, $name");
    _tmplDefs.add(name);
    if (verbose)
      print("Generate template $name...");

    var desc = elem.attributes["description"],
      args = elem.attributes["args"];
    if (desc == null)
      desc = "Template, $name, for creating views.";
    _checkAttrs(elem, _templAllowed);

    _startTemplate(args);
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
    args = args != null && !args.trim().isEmpty ? ", $args": "";
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
          _warning("Template doesn't support $attr", node);
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
        _warning("The control attribute is empty", node);
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
          _writeln("${_pre}final $ctrlName = $ctrlVar;");

        final args = "View beforeChild";
        _startTemplate(args);
        _outBeginTempl(ctrlTempl, args, node.lineNumber);
        _indent();
      }
    }

    var vi = _current.startView(), viewVar = vi.name, parentVar = vi.parent;

    _write("\n$_pre//$lineInfo");
    _write(bText ? _toComment(attrs["text"]): _toTagComment(name, attrs));
    _write("\n${_pre}final $viewVar = ");
    if (bText) { 
      _write("new $name()");
    } else {//if bText, ctrlVar must be null (since no control attr)
      _write("_this_ = ");

      //we have to assign view as soon as possible since attributes might refer
      //to it. also control's template might be used in other place, so better to
      //check if it is null before assignment
      if (ctrlVar != null)
        _write("($ctrlVar.view == null ? $ctrlVar.view = new $name(): new $name())");
      else
        _write("new $name()");
    }

    for (final attr in attrs.keys) {
      String val = attrs[attr];
      if (attr.startsWith("data-")) {
        _write('\n$_pre  ..dataAttributes["${attr.substring(5)}"] = ${_unwrap(val)}');
      } else if (attr.startsWith("on.")) { //action
        final event = attr.substring(3);
        if (!_isValidId(event))
          throw new CompileException("${_loc(node)}Illegal event name, $attr");

        String name, act = val;
        final i = act.indexOf('.');
        if (i >= 0) {
          name = act.substring(0, i).trim();
          act = act.substring(i + 1);
        }

        if (!(act = act.trim()).isEmpty || name != null) {
          if ((name != null && !_isValidId(name)) || !_isValidId(act))
            throw new CompileException("${_loc(node)}Illegal action, $val");

          if (name == null)
            name = _current.lastCtrl;
          name = name != null ? "$name.": "";

          _write('''
\n$_pre  ..on.$event.add((_e){
$_pre    $name$act(_e);
$_pre    ${name}onCommand('$act', _e);
$_pre  })''');
        }
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
$_pre  parent.addChild($viewVar${_current.beforeArg});
${_pre}${_current.listVar}.add($viewVar);''');

    for (final n in node.nodes)
      _do(n);
    _current.endView();

    if (control != null) {
      _undent();
      _outEndTempl();
      _endTemplate();

      vi = _current.startView(); viewVar = vi.name; parentVar = vi.parent;

      var parentArg, beforeArg;
      if (parentVar != null) {
        parentArg = parentVar;
        beforeArg = "";
      } else {
        parentArg = "parent";
        beforeArg = _current.beforeArg;
        if (!beforeArg.isEmpty)
          beforeArg = ", beforeChild: beforeChild";
      }
      _writeln('''
$_pre$ctrlVar.template = $ctrlTempl;
${_pre}final $viewVar = $ctrlTempl(parent: $parentArg$beforeArg)[0];''');
      if (parentVar == null)
        _writeln("${_pre}${_current.listVar}.add($viewVar);");
      _writeln("$_pre$ctrlVar.onRender();");

      _current.endView();
      _current.endCtrl();
    }
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
      throw new CompileException("${_loc(elem)}The $attr attribute is required");
    return val;
  }
  void _checkAttrs(Element elem, Set<String> allowedAttrs) {
    for (final attr in elem.attributes.keys)
      if (!allowedAttrs.contains(attr))
        _warning("The $attr attribute not allowed in ${elem.tagName}", elem);
  }

  _indent() => _pre = "$_pre  ";
  _undent() => _pre = _pre.substring(0, _pre.length - 2);

  //Returns the information about the give node
  String _loc(Node node) {
    final sb = new StringBuffer();
    if (sourceName != null)
      sb.add(sourceName).add(':');
    final ln = node.lineNumber;
    if (ln != null)
      sb.add(ln).add(':');
    return sb.isEmpty ? '': sb.add(' ').toString();
  }
  ///show warning messages
  void _warning(String msg, [Node node]) {
    print("${_loc(node)}Warning: $msg");
  }

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
  void _startTemplate(String args) {
    _tmplInfos.addFirst(_current = new _TemplateInfo(_current, args));
  }
  void _endTemplate() {
    _tmplInfos.removeFirst();
    _current = _tmplInfos.isEmpty ? null: _tmplInfos.first;
  }
}
