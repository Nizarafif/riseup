import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riseup/main.dart';

void main() {
  testWidgets('RiseUp basic initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Memverifikasi bahwa indikator loading awal dirender karena inisialisasi async
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
