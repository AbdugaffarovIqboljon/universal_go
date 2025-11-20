import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_go/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:universal_go/features/cart/data/datasources/cart_local_datasource.dart';
import 'package:universal_go/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:universal_go/features/cart/domain/repositories/cart_repository.dart';
import 'package:universal_go/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:universal_go/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:universal_go/features/cart/presentation/bloc/cart_bloc.dart';

import 'package:universal_go/core/services/firebase/firebase_service_impl.dart';
import 'package:universal_go/core/services/map/location_service.dart';
import 'package:universal_go/core/services/map/location_service_impl.dart';

final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Firebase
  await FirebaseServiceImpl.initialize();
  
  // External dependencies
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseServiceImpl.auth);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseServiceImpl.firestore);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseServiceImpl.storage);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseServiceImpl.messaging);
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // Services
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  
  // Auth Dependencies
  sl.registerLazySingleton(() => AuthRepositoryImpl(
    auth: sl<FirebaseAuth>(),
    firestore: sl<FirebaseFirestore>(),
  ));
  
  // Cart Dependencies
  sl.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );
  
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(localDataSource: sl<CartLocalDataSource>()),
  );
  
  sl.registerLazySingleton(() => GetCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => AddToCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl<CartRepository>()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl<CartRepository>()));
  
  sl.registerFactory(() => CartBloc(
    getCartUseCase: sl<GetCartUseCase>(),
    addToCartUseCase: sl<AddToCartUseCase>(),
    removeFromCartUseCase: sl<RemoveFromCartUseCase>(),
    updateCartQuantityUseCase: sl<UpdateCartQuantityUseCase>(),
    clearCartUseCase: sl<ClearCartUseCase>(),
  ));
}
