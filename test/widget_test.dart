import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whattoeat/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Proje artik Riverpod ve SharedPreferences gerektirdigi için 
    // test ortaminda ProviderScope gereklidir.
    // Varsayilan testi projedeki sinif adina gore guncelledik.
    await tester.pumpWidget(const ProviderScope(child: WhatToEatApp()));
    expect(find.byType(WhatToEatApp), findsOneWidget);
  });
}
