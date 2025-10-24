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
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object> get props => [email, password, name, role];
}
