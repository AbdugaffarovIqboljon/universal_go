import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  
  Future<Either<Failure, UserEntity>> getCurrentUser();
  
  Future<Either<Failure, void>> signOut();
  
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  });
}
