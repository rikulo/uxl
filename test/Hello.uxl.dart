//Auto-generated by UXL Compiler
//Source: test/Hello.uxl.xml

//1#
import "dart:math";
import "package:rikulo/view.dart";
import "package:rikulo_uxl/uxl.dart";

void main() {
  //Hello()[0]..addToDocument();
  new View()..addChild(Hello()[0])..addToDocument();
}

class HelloControl extends Control {
  String message = messages[0];

  void change(e) {
    message = nextMessage();
  }
}

String nextMessage() => messages[random.nextInt(4)];
final Random random = new Random();
const messages = const ['great', 'wicked cool', 'sweet', 'fantastic'];

/** Template, Hello, for creating views. */
List<View> Hello({View parent}) { //24#
  List<View> _rv = new List(); View _this_;

  final _c0 = new HelloControl();
  final ctrl = _c0;
  List<View> _c0T({View parent, View beforeChild}) { //25#
    List<View> _rva = new List(); View _this_;

    //25# <Panel layout="type:linear; orient:...>
    final _va0 = _this_ = (_c0.view == null ? _c0.view = new Panel(): new Panel())
      ..layout.text = '''type:linear; orient: vertical; gap: 12; spacing: 0'''
      ..profile.text = '''location: center center; width: 130; height: 80''';
    if (parent != null)
      parent.addChild(_va0, beforeChild);
    _rva.add(_va0);

    //UXL is ${ctrl.message}!
    final _va0_0 = new TextView()
      ..text = '''UXL is ${ctrl.message}!''';
    _va0.addChild(_va0_0);

    //29# <Button text="Change" on.click="change">
    final _va0_1 = _this_ = new Button()
      ..text = '''Change'''
      ..on.click.add((_e){
        _c0.change(_e);
        _c0.onCommand('change', _e);
      });
    _va0.addChild(_va0_1);
    return _rva;
  }
  _c0.template = _c0T;
  final _v0 = _c0T(parent: parent)[0];
  _rv.add(_v0);
  _c0.onRender();
  return _rv;
}
