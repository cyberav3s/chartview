import 'package:chartview/core/constants/app_theme.dart';
import 'package:chartview/features/market/presentation/bloc/market_bloc.dart';
import 'package:chartview/features/positions/presentation/bloc/positions_bloc.dart';
import 'package:chartview/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'features/authentication/presentation/pages/home_page.dart';
import 'package:chartview/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MarketBloc()),
        BlocProvider(create: (_) => PositionsBloc()),
        BlocProvider(create: (_) => sl<WatchlistBloc>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
