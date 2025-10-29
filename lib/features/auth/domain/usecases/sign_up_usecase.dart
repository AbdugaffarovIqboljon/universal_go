import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/features/auth/domain/entities/user_entity.dart';
import 'package:universal_go/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithPhoneAndPassword(
      phoneNumber: params.phoneNumber,
      password: params.password,
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class SignUpParams extends Equatable {
  final String phoneNumber;
  final String password;
  final String firstName;
  final String lastName;

  const SignUpParams({
    required this.phoneNumber,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [phoneNumber, password, firstName, lastName];
}
