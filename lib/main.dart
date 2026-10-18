import 'package:crypto_mobile/bloc/coin_bloc.dart';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/market_stats_bloc.dart';
import 'package:crypto_mobile/bloc/market_stats_event.dart';
import 'package:crypto_mobile/bloc/watchlist_bloc.dart';
import 'package:crypto_mobile/bloc/watchlist_event.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/screens/splash_screen.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
            title: 'Cryptography',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColors.scaffoldBackground,
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          ),
        ),
      ),
    );
  }
}
