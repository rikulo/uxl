//Sample Code: ScrollView with EL

import 'dart:html';
import 'package:rikulo/view.dart';
import 'package:rikulo/html.dart';
part "ScrollView.uxl.dart";

void main() {
  final View mainView = new View()..addToDocument();
  ScrollViewTemplate(parent: mainView);
}
