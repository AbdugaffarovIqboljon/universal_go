import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/features/auth/domain/entities/user_entity.dart';
import 'package:universal_go/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCaseNoParams<UserEntity> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
