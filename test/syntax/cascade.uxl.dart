//Auto-generated by UXL Compiler
//Source: test/syntax/cascade.uxl.xml

//1#
import "package:rikulo_ui/view.dart";

class A {
	String foo;
}
class TestView extends View {
	A get a => null;
}

/** Template, foo, for creating views. */
List<View> foo({View parent}) { //12#
  List<View> _rv = new List(); View _this_;

  //13# <TextView>
  final _v0 = _this_ = new TextView();
  if (parent != null)
    parent.addChild(_v0);
  _rv.add(_v0);

  //14# <TestView a.foo="a & < b">
  final _v1 = _this_ = new TestView()
    ..a.foo = '''a & < b''';
  if (parent != null)
    parent.addChild(_v1);
  _rv.add(_v1);

  //& in CDATA\n  Test2 & < ano...
  final _v1_0 = new TextView()
    ..text = '''& in CDATA
  Test2 & < another2''';
  _v1.addChild(_v1_0);

  //17# <Button>
  final _v1_1 = _this_ = new Button();
  _v1.addChild(_v1_1);
  return _rv;
}
