//Auto-generated by UXL Compiler
//Source: test/syntax/syntax.uxl.xml

//4#
library foo;

import 'package:rikulo/view.dart';
import 'package:rikulo_uxl/uxl.dart';

/** A template to create a group of input views */
List<View> Inputs({View parent, friends, zoo}) { //13#
  List<View> _rv = new List(); View _this_;

  //15# <View layout="type: linear; orient:...>
  final _v0 = _this_ = new View()
    ..layout.text = '''type: linear; orient: vertical'''
    ..style.cssText = '''border: 2px solid #333''';
  if (parent != null)
    parent.addChild(_v0);
  _rv.add(_v0);

  //16# <InputHead label="Form">
  final _v0_0 = InputHead(parent: _v0, label: '''Form''');

  for (var each in ['text', 'password', 'multiline', 'number', 'date', 'color']) {

    //17# <View forEach="each in ['text', 'pas...>
    final _v0_1 = _this_ = new View()
      ..layout.text = '''type: linear; align: center; spacing: 0 3'''
      ..classes.add("foo1")
      ..classes.add("foo2");
    _v0.addChild(_v0_1);

    //${each}
    final _v0_1_0 = new TextView()
      ..text = '''${each}''';
    _v0_1.addChild(_v0_1_0);

    if (each != 'multiline') {

      //20# <TextBox type="$each" if="each != 'm...>
      final _v0_1_1 = _this_ = new TextBox()
        ..type = each;
      _v0_1.addChild(_v0_1_1);
    }

    if (each == 'multiline') {

      //21# <TextArea if="each == 'multiline'">
      final _v0_1_2 = _this_ = new TextArea();
      _v0_1.addChild(_v0_1_2);
    }
  }

  /** Template, InputDetail, for creating views. */
  List<View> InputDetail({View parent, each}) { //25#
    List<View> _rva = new List(); View _this_;

    //26# <ListHead label="${each.name}" image...>
    final _va0 = _this_ = new ListHead()
      ..label = each.name
      ..image = each.photo;
    if (parent != null)
      parent.addChild(_va0);
    _rva.add(_va0);

    //27# <InputHead label="${each.description}">
    final _va1 = InputHead(parent: parent, label: each.description);
    _rva.addAll(_va1);
    return _rva;
  }

  //29# <ListView model="${friends}" data-de...>
  final _v1 = _this_ = new ListView()
    ..model = friends
    ..dataAttributes["detail"] = InputDetail
    ..dataAttributes["header"] = InputHeader;
  if (parent != null)
    parent.addChild(_v1);
  _rv.add(_v1);

  final _c0 = new MagicControl();
  List<View> _c0T({View parent, View beforeChild}) { //31#
    List<View> _rva = new List(); View _this_;

    //31# <View layout="type: linear; orient:...>
    final _va0 = _this_ = (_c0.view == null ? _c0.view = new View(): new View())
      ..layout.text = '''type: linear; orient: vertical''';
    if (parent != null)
      parent.addChild(_va0, beforeChild);
    _rva.add(_va0);

    for (var animal in zoo.animals) {

      //32# <MagicBox owner="${animal}" forEach=...>
      final _va0_0 = MagicBox(parent: _va0, owner: animal);
    }

    //33# <TextView html="\n      ${friends[0]...>
    final _va0_1 = _this_ = new TextView()
      ..html = '''
      ${friends[0]}
      <ul>
        <li>abc</li>
        <li>xyz</li>
      </ul>''';
    _va0.addChild(_va0_1);
    return _rva;
  }
  _c0.template = _c0T;
  final _v2 = _c0T(parent: parent)[0];
  _rv.add(_v2);
  _c0.onRender();

  //41# <AnotherFood>
  final _v3 = AnotherFood(parent: parent);
  _rv.addAll(_v3);
  return _rv;
}

/** Template, AnotherFood, for creating views. */
List<View> AnotherFood({View parent, foods, classes}) { //44#
  List<View> _rv = new List(); View _this_;

  for (var each in foods) {

    //$each is found.
    final _v0 = new TextView()
      ..text = '''$each is found.''';
    if (parent != null)
      parent.addChild(_v0);
    _rv.add(_v0);

    if (each == 'orange') {

      //48# <View class="hilite">
      final _v1 = _this_ = new View()
        ..classes.add("hilite");
      if (parent != null)
        parent.addChild(_v1);
      _rv.add(_v1);

      //This is nice.
      final _v1_0 = new TextView()
        ..text = '''This is nice.''';
      _v1.addChild(_v1_0);
    }

    //More and more to come.
    final _v2 = new TextView()
      ..text = '''More and more to come.''';
    if (parent != null)
      parent.addChild(_v2);
    _rv.add(_v2);
  }

  //52# <View tag="ul" tag-contentEditable="...>
  final _v3 = _this_ = new View.tag('ul')
    ..node.contentEditable = '''true'''
    ..id = '''abc''';
  if (parent != null)
    parent.addChild(_v3);
  _rv.add(_v3);

  //53# <View tag="li" class="${classes}">
  final _v4 = _this_ = new View.tag('li')
    ..classes.addAll('''${classes}'''.split(' '))
    ..node.innerHtml = '''
    this is inner text.
    
    Not TextView
    
  ''';
  if (parent != null)
    parent.addChild(_v4);
  _rv.add(_v4);
  return _rv;
}

//61#
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

class MagicControl extends Control {
  
}
