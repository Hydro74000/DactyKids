import 'package:dactykids/presentation/screens/dactykids_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home app bar actions are reachable and activable by keyboard',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(1200, 900));

    await tester.pumpWidget(const DactyKidsApp());
    await tester.pump(const Duration(seconds: 3));

    final visitedTooltips = <String>{};
    for (var index = 0; index < 16; index++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump(const Duration(milliseconds: 80));
      final tooltip = _focusedTooltip();
      if (tooltip != null) {
        visitedTooltips.add(tooltip);
      }
      if (tooltip == 'Parent') {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump(const Duration(seconds: 1));
        break;
      }
    }

    expect(visitedTooltips, containsAll(['Profil', 'Mini-jeux', 'Reglages']));
    expect(find.text('Parent / enseignant'), findsOneWidget);
    expect(find.text('Progression'), findsOneWidget);
  });
}

String? _focusedTooltip() {
  final context = FocusManager.instance.primaryFocus?.context;
  if (context == null) {
    return null;
  }

  String? tooltip;
  void inspect(Element element) {
    final widget = element.widget;
    if (widget is Tooltip) {
      tooltip = widget.message;
    }
  }

  context.visitAncestorElements((element) {
    inspect(element);
    return tooltip == null;
  });
  context.visitChildElements(inspect);
  return tooltip;
}
