// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart'
    show WidgetTester, expect, find, findsOneWidget, testWidgets;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:previsao_tempo_cptec/main.dart';
import 'package:previsao_tempo_cptec/services/cptec_service.dart';
import 'package:previsao_tempo_cptec/services/storage_service.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      PrevisaoTempoApp(
        cptecService: CptecService(),
        storageService: StorageService(await SharedPreferences.getInstance()),
      ),
    );

    expect(find.byType(PrevisaoTempoApp), findsOneWidget);
  });
}
