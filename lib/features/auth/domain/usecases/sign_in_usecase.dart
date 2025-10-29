import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/features/auth/domain/entities/user_entity.dart';
import 'package:universal_go/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithPhoneAndPassword(
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  final String phoneNumber;
  final String password;

  const SignInParams({
    required this.phoneNumber,
    required this.password,
  });

  @override
  List<Object> get props => [phoneNumber, password];
}
