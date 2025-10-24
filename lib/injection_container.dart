import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:universal_go/features/auth/data/repositories/auth_repository_impl.dart';

import 'package:universal_go/core/services/firebase/firebase_service_impl.dart';
import 'package:universal_go/core/services/location/location_service.dart';
import 'package:universal_go/core/services/location/location_service_impl.dart';

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
  
  // Services
  sl.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  
  // Auth Dependencies
  sl.registerLazySingleton(() => AuthRepositoryImpl(
    auth: sl<FirebaseAuth>(),
    firestore: sl<FirebaseFirestore>(),
  ));
  
  // TODO: Register more repositories, use cases, and blocs here
  // This will be expanded as we implement each feature
}
