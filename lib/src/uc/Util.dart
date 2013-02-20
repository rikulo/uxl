//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Mon, Nov 05, 2012 12:14:19 PM
// Author: tomyeh
part of rikulo_uc;

/** A compiling exception.
 */
class CompileException implements Exception {
  final String message;

  const CompileException(String this.message);
  String toString() => "CompileException($message)";
}

///Current variable's information
class _VarInfo {
  final String name;
  final String parent;
  int _nextId = 0;

  _VarInfo(_VarInfo prev, this.name): parent = prev != null ? prev.name: null;
}

///Current template's information
class _TemplateInfo {
  ///Variable name referencing to the return list
  final listVar;
  final _TemplateInfo prev;
  ///A string inserted to parent.addChild(...$beforeChild)
  final String beforeArg;
  ///A prefix representing this template info (in a stack of template infos)
  final String _idep;
  final Queue<_VarInfo> _vars = new Queue();
  final Queue<String> _ctrls = new Queue();
  int _nextId = 0, _nextCtrlId = 0;

  factory _TemplateInfo(_TemplateInfo prev, String args) {
    var idep, listVar;
    if (prev == null) {
      idep = "";
      listVar = "_rv";
    } else {
      idep = prev._idep;
      idep = idep.isEmpty ? "a": idep == "z" ? "A":
        new String.fromCharCodes([idep.codeUnitAt(0) + 1]);
        //assume at most 1+26+26 depth
      listVar = "_rv${idep}";
    }
    return new _TemplateInfo._(prev, idep, listVar,
      args != null && _hasWord(args, "beforeChild") ? ", beforeChild": "");
  }
  _TemplateInfo._(this.prev, this._idep, this.listVar, this.beforeArg);

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

//FUTURE: use rikulo-commons instead
const _ZERO = 48, _LOWER_A = 97, _UPPER_A = 65;

bool _isLetter(String char) {
  if (char == null) return false;
  int cc = char.codeUnitAt(0);
  return cc >= _LOWER_A && cc < _LOWER_A + 26 || cc >= _UPPER_A && cc < _UPPER_A + 26;
}
bool _isDigit(String char) {
  if (char == null) return false;
  int cc = char.codeUnitAt(0);
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

bool _hasWord(String s, String w) {
  for (int i = 0, j; (j = s.indexOf(w, i)) >= 0;) {
    i = j + 1;
    if ((j == 0 || !_isLetter(s[j - 1]))
    && ((j += w.length) >= s.length || !_isLetter(s[j])))
      return true;
  }
  return false;
}

bool _containsEL(String s) {
  for (int i = 0, j; (j = s.indexOf("\${", i)) >= 0;) {
    if (j == 0 || s[j - 1] != '\\')
      return true;
    i = j + 2;
  }
  return false;
}