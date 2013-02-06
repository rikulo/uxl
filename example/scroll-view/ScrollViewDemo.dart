//Sample Code: ScrollView with EL
library ScrollViewDemo;

import 'package:rikulo_ui/view.dart';
import 'package:rikulo_ui/html.dart';
part "ScrollView.uxl.dart";

void main() {
  final View mainView = new View()..addToDocument();
  ScrollViewTemplate(parent: mainView);
}
