//Auto-generated by UXL Compiler
//Source: test/syntax.uxl.xml

library foo;

import 'package:rikulo/view.dart';


/** A template to create a group of input views */
List<View> Inputs({parent, friends, zoo}) {
  List<View> _vcr_ = new List();
  var _this_;

  //<View layout="type: linear; orient: vertical" style="border: 2px solid #333">
  final _v0_ = _this_ = new View()
    ..layout.text = '''type: linear; orient: vertical'''
    ..style.cssText = '''border: 2px solid #333''';
  if (parent != null)
    parent.addChild(_v0_);
  _vcr_.add(_v0_);

  //<InputHead label="Form">
  final _v0_0_ = _this_ =
    InputHead(parent: _v0_, label: '''Form''');

  for (var each in ['text', 'password', 'multiline', 'number', 'date', 'color']) {

    //<View forEach="each in ['text', 'password', 'multiline', 'number', 'date',...>
    final _v0_1_ = _this_ = new View()
      ..layout.text = '''type: linear; align: center; spacing: 0 3'''
      ..classes.add("foo1")
      ..classes.add("foo2");
    _v0_.addChild(_v0_1_);

    //${each}
    final _v0_1_0_ = _this_ = new TextView()
      ..text = '''${each}''';
    _v0_1_.addChild(_v0_1_0_);

    if (each != 'multiline') {

      //<TextBox type="$each" if="each != 'multiline'">
      final _v0_1_1_ = _this_ = new TextBox()
        ..type = each;
      _v0_1_.addChild(_v0_1_1_);
    }

    if (each == 'multiline') {

      //<MultilineBox if="each == 'multiline'">
      final _v0_1_2_ = _this_ = new MultilineBox();
      _v0_1_.addChild(_v0_1_2_);
    }
  }

  //<ListView model="${friends}" data-detail="${InputDetail}" data-header="${In...>
  final _v1_ = _this_ = new ListView()
    ..model = friends
    ..dataAttributes["detail"] = InputDetail
    ..dataAttributes["header"] = InputHeader;
  if (parent != null)
    parent.addChild(_v1_);
  _vcr_.add(_v1_);

  //<View layout="type: linear; orient: vertical" control="MagicControl">
  final _v2_ = _this_ = new View()
    ..layout.text = '''type: linear; orient: vertical''';
  if (parent != null)
    parent.addChild(_v2_);
  _vcr_.add(_v2_);

  for (var animal in zoo.animals) {

    //<MagicBox owner="${animal}" forEach="animal in zoo.animals">
    final _v2_0_ = _this_ =
      MagicBox(parent: _v2_, owner: animal);
  }

  //<TextView html="       ${friends[0]}       <ul>         <li>abc</li>...>
  final _v2_1_ = _this_ = new TextView()
    ..html = '''
      ${friends[0]}
      <ul>
        <li>abc</li>
        <li>xyz</li>
      </ul>''';
  _v2_.addChild(_v2_1_);
  (MagicControl)(_v2_);
  return _vcr_;
}


/** Template, AnotherFood, for creating views. */
List<View> AnotherFood({parent, foods}) {
  List<View> _vcr_ = new List();
  var _this_;

  for (var each in foods) {

    //$each is found.
    final _v0_ = _this_ = new TextView()
      ..text = '''$each is found.''';
    if (parent != null)
      parent.addChild(_v0_);
    _vcr_.add(_v0_);

    if (each == 'orange') {

      //<View class="hilite">
      final _v1_ = _this_ = new View()
        ..classes.add("hilite");
      if (parent != null)
        parent.addChild(_v1_);
      _vcr_.add(_v1_);

      //This is nice.
      final _v1_0_ = _this_ = new TextView()
        ..text = '''This is nice.''';
      _v1_.addChild(_v1_0_);
    }

    //More and more to come.
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


/** Template, InputDetail, for creating views. */
List<View> InputDetail({parent, each}) {
  List<View> _vcr_ = new List();
  var _this_;

  //<ListHead label="${each.name}" image="${each.photo}">
  final _v0_ = _this_ = new ListHead()
    ..label = each.name
    ..image = each.photo;
  if (parent != null)
    parent.addChild(_v0_);
  _vcr_.add(_v0_);

  //<InputHead label="${each.description}">
  final _v1_ = _this_ =
    InputHead(parent: parent, label: each.description);
  _vcr_.addAll(_v1_);
  return _vcr_;
}
