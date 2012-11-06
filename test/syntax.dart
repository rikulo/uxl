//Auto-generated by UXL Compiler
//Source: test/syntax.xml


library foo;

import 'package:rikulo/view.dart';


/** A template to create a group of input views */
List<View> Inputs({parent, friends, zoo}) {
  List<View> _vcr_ = new List();
  var _this_;
  final _v0_ = _this_ = new View()
    ..layout.text = '''type: linear; orient: vertical'''
    ..style.cssText = '''border: 2px solid #333''';
  if (parent != null)
    parent.addChild(_v0_);
  _vcr_.add(_v0_);

  final _v0_0_ = _this_ =
    InputHead(parent: _v0_, label: '''Form''');

  for (final each in ['text', 'password', 'multiline', 'number', 'date', 'color']) {
    final _v0_1_ = _this_ = new View()
      ..layout.text = '''type: linear; align: center; spacing: 0 3'''
      ..classes.add("foo1")
      ..classes.add("foo2");
    _v0_.addChild(_v0_1_);

    final _v0_1_0_ = _this_ = new TextView()
      ..text = '''${each}''';
    _v0_1_.addChild(_v0_1_0_);

    if (each != 'multiline') {
      final _v0_1_1_ = _this_ = new TextBox()
        ..type = each;
      _v0_1_.addChild(_v0_1_1_);

    }

    if (each == 'multiline') {
      final _v0_1_2_ = _this_ = new MultilineBox();
      _v0_1_.addChild(_v0_1_2_);

    }

  }

  final _v1_ = _this_ = new ListView()
    ..model = friends
    ..dataAttributes["detail"] = InputDetail
    ..dataAttributes["header"] = InputHeader;
  if (parent != null)
    parent.addChild(_v1_);
  _vcr_.add(_v1_);

  final _v1_0_ = _this_ = new View()
    ..layout.text = '''type: linear; orient: vertical''';
  _v1_.addChild(_v1_0_);

  for (final animal in zoo.animals) {
    final _v1_0_0_ = _this_ =
      MagicBox(parent: _v1_0_, owner: animal);

  }

  final _v1_0_1_ = _this_ = new TextView()
    ..html = '''
      ${friends[0]}
      <ul>
        <li>abc</li>
        <li>xyz</li>
      </ul>''';
  _v1_0_.addChild(_v1_0_1_);

  (MagicControl)(_v1_0_);
  return _vcr_;
}


/** A template to create views. */
List<View> AnotherFood({parent, foods}) {
  List<View> _vcr_ = new List();
  var _this_;
  for (final each in foods) {
    final _v0_ = _this_ = new TextView()
      ..text = '''$each is found.''';
    if (parent != null)
      parent.addChild(_v0_);
    _vcr_.add(_v0_);

    if (each == 'orange') {
      final _v1_ = _this_ = new View()
        ..classes.add("hilite");
      if (parent != null)
        parent.addChild(_v1_);
      _vcr_.add(_v1_);

      final _v1_0_ = _this_ = new TextView()
        ..text = '''This is nice.''';
      _v1_.addChild(_v1_0_);

    }

    final _v2_ = _this_ = new TextView()
      ..text = '''More and more to come.''';
    if (parent != null)
      parent.addChild(_v2_);
    _vcr_.add(_v2_);

  }

  return _vcr_;
}

//used to make the generated dart error free
List<View> MagicBox({parent, owner}) => new List();
List<View> InputHead({parent, label}) => new List();

class InputHeader {
}
class ListView extends View {
  var model;
}
class ListHead extends View {
  String label;
  String image;
}
void MagicControl(View view) {
}


/** A template to create views. */
List<View> InputDetail({parent, each}) {
  List<View> _vcr_ = new List();
  var _this_;
  final _v0_ = _this_ = new ListHead()
    ..label = each.name
    ..image = each.photo;
  if (parent != null)
    parent.addChild(_v0_);
  _vcr_.add(_v0_);

  final _v1_ = _this_ =
    InputHead(parent: parent, label: each.description);
  _vcr_.addAll(_v1_);

  return _vcr_;
}