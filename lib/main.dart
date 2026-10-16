import 'package:crypto_mobile/bloc/coin_bloc.dart';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/screens/home_screen.dart';
import 'package:crypto_mobile/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const MyApp());

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
          ],
          child: MaterialApp(
            title: 'Crypto Mobile',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
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
}
