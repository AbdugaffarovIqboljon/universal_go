import 'package:dartz/dartz.dart';
import 'package:universal_go/core/errors/failures.dart';
import 'package:universal_go/core/base/usecase.dart';
import 'package:universal_go/features/auth/domain/repositories/auth_repository.dart';

class SignOutUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}
