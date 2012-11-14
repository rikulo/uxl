//Auto-generated by UXL Compiler
//Source: example/scroll-view/ScrollView.uxl.xml

/** Template, ScrollViewTemplate, for creating views. */
List<View> ScrollViewTemplate({View parent, rows: 30, cols: 30}) { //3#
  List<View> _rv = new List();
  View _this_;

  //4# <ScrollView class="scroll-view" prof...>
  final _v0 = (_this_ = new ScrollView())
    ..classes.add("scroll-view")
    ..profile.text = '''location: center center; width: 80%; height: 80%''';
  if (parent != null)
    parent.addChild(_v0);
  _rv.add(_v0);

  for (var r = 0; r < rows; ++r) {

    for (var c = 0; c < cols; ++c) {

      //8# <View style="border: 1px solid #553;...>
      final _v0_0 = (_this_ = new View())
        ..style.cssText = '''border: 1px solid #553; background-color: ${CSS.color(250 - r * 4, 250 - c * 4, 200)}'''
        ..left = r * 50 + 2
        ..top = c * 50 + 2
        ..width = 46
        ..height = 46;
      _v0.addChild(_v0_0);
    }
  }
  return _rv;
}
