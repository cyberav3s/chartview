import 'package:chartview/core/database/local_database.dart';
import 'package:chartview/features/positions/presentation/bloc/positions_bloc.dart';
import 'package:chartview/features/watchlist/presentation/bloc/watchlist_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:chartview/features/market/presentation/bloc/market_bloc.dart';
import 'package:chartview/features/chart/presentation/bloc/chart_bloc.dart';
import 'package:chartview/features/watchlist/data/repositories/watchlist_repository_impl.dart';
import 'package:chartview/features/watchlist/domain/repositories/watchlist_repository.dart';
import 'package:chartview/features/watchlist/domain/usecases/watchlist_usecases.dart';
import 'features/watchlist/data/datasources/watchlist_remote_data_source.dart';

final sl = GetIt.instance;

class ServiceLocator {
  static void init() {
    _resources();
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }
  
  static void _resources() {
    sl.registerLazySingleton<LocalDatabase>(
      () => LocalDatabase(),
    );
  }

  static void _registerDataSources() {
    sl.registerLazySingleton<WatchlistLocalDataSource>(
      () => WatchlistLocalDataSourceImpl(sl()),
    );
  }

  static void _registerRepositories() {
    sl.registerLazySingleton<WatchlistRepository>(
      () => WatchlistRepositoryImpl(sl()),
    );
  }

  static void _registerUseCases() {
    _registerWatchlistUseCases();
  }

  static void _registerWatchlistUseCases() {
    sl.registerLazySingleton(() => AddSymbol(sl()));
    sl.registerLazySingleton(() => GetFolders(sl()));
    sl.registerLazySingleton(() => CreateFolder(sl()));
    sl.registerLazySingleton(() => RenameFolder(sl()));
    sl.registerLazySingleton(() => DeleteFolder(sl()));
    sl.registerLazySingleton(() => ReorderFolders(sl()));
    sl.registerLazySingleton(() => CreateSection(sl()));
    sl.registerLazySingleton(() => RenameSection(sl()));
    sl.registerLazySingleton(() => DeleteSection(sl()));
    sl.registerLazySingleton(() => SetSectionCollapsed(sl()));
    sl.registerLazySingleton(() => RemoveSymbol(sl()));
    sl.registerLazySingleton(() => ReorderSymbols(sl()));
    sl.registerLazySingleton(() => MoveSymbol(sl()));
  }

  static void _registerBlocs() {
    sl.registerFactory(() => PositionsBloc());
    sl.registerFactory(() => MarketBloc());
    sl.registerFactory(() => ChartBloc());
    sl.registerFactory(
      () => WatchlistBloc(
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
      ),
    );
  }
}
