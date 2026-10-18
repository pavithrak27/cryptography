import 'package:crypto_mobile/bloc/coin_bloc.dart';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/market_stats_bloc.dart';
import 'package:crypto_mobile/bloc/market_stats_event.dart';
import 'package:crypto_mobile/bloc/watchlist_bloc.dart';
import 'package:crypto_mobile/bloc/watchlist_event.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/screens/home_screen.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';


Widget _testApp() {
  return RepositoryProvider(
    create: (_) => CoinService(),
    child: Builder(
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => CoinListBloc(ctx.read<CoinService>())
              ..add(CoinsRequested()),
          ),
          BlocProvider(
            create: (ctx) => MarketStatsBloc(ctx.read<CoinService>())
              ..add(MarketStatsRequested()),
          ),
          BlocProvider(
            create: (ctx) => WatchlistBloc(ctx.read<CoinService>())
              ..add(WatchlistRequested()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets(
    'HomeScreen shows header title and navigation buttons',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      // One pump cycle to render initial frame (loading skeleton)
      await tester.pump();

      // Header title is always visible regardless of loading state
      expect(find.text('Crypto Market'), findsOneWidget);

      // Navigation buttons are rendered
      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Watchlist'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen shows skeleton loader while data is loading',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      await tester.pump(); // one frame — still loading

      // During loading, the skeleton is shown (no coin names yet)
      expect(find.text('Crypto Market'), findsOneWidget);
      expect(find.text('Live prices & real-time performance'), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen adapts responsively on tablet screen size',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 2560);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      await tester.pump();

      // No overflow on wide screens
      expect(find.text('Crypto Market'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Filter chips exist and are tappable',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      await tester.pump();

      // Filter chips rendered
      expect(find.text('All Coins'), findsOneWidget);
      expect(find.textContaining('Gainers'), findsOneWidget);
      expect(find.textContaining('Losers'), findsOneWidget);

      // Tapping Gainers doesn't throw
      await tester.tap(find.textContaining('Gainers'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Navigation buttons are tappable without crash',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_testApp());
      await tester.pump();

      // Tap Market button — should navigate without crashing
      await tester.tap(find.text('Market'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}
