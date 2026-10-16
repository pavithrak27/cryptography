import 'package:crypto_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HomeScreen renders coin cards for Bitcoin, Ethereum, Tether',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify coin names are rendered (as separate cards now)
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Ethereum'), findsOneWidget);
    expect(find.text('Tether'), findsOneWidget);

    // Verify coin symbols
    expect(find.text('BTC'), findsOneWidget);
    expect(find.text('ETH'), findsOneWidget);
    expect(find.text('USDT'), findsOneWidget);

    // Verify rank badges
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('#3'), findsOneWidget);

    // Verify percentage values rendered
    expect(find.textContaining('%'), findsWidgets);
  });

  testWidgets('HomeScreen adapts responsively on tablet screen size',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 2560);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // No overflow on wide screens
    expect(find.text('Crypto Market'), findsOneWidget);
    expect(find.text('Bitcoin'), findsOneWidget);
  });

  testWidgets('Filter chips exist and are tappable',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify filter chips are present
    expect(find.text('All Coins'), findsOneWidget);
    expect(find.textContaining('Gainers'), findsOneWidget);
    expect(find.textContaining('Losers'), findsOneWidget);

    // Tap Gainers chip
    await tester.tap(find.textContaining('Gainers'));
    await tester.pumpAndSettle();

    // Still renders (filter applied)
    expect(find.text('Bitcoin'), findsOneWidget);
  });
}
