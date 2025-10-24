import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/errors/exceptions.dart';
import 'package:universal_go/features/auth/domain/entities/user_entity.dart';
import 'package:universal_go/features/auth/domain/repositories/auth_repository.dart';
import 'package:universal_go/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth, _firestore = firestore;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return const Left(AuthFailure('Sign in failed'));
      }
      
      final user = await _getUserFromFirestore(credential.user!.uid);
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) {
        return const Left(AuthFailure('Sign up failed'));
      }
      
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toJson());
      
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(AuthFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('No user signed in'));
      }
      
      final userEntity = await _getUserFromFirestore(user.uid);
      return Right(userEntity);
    } catch (e) {
      return Left(AuthFailure('Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      
      await _firestore.collection('users').doc(userId).update(updateData);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Profile update failed: ${e.toString()}'));
    }
  }

  Future<UserEntity> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw const AuthException('User not found');
    }
    return UserModel.fromJson(doc.data()!);
  }
}
