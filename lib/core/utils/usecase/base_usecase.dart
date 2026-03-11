// lib/core/utils/usecase/base_usecase.dart
import 'package:chartview/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

abstract class UseCase<T, P> {
  Future<Either<Failure, T>> call(P p);
}

abstract class StreamUseCase<T, P> {
  Stream<T> call(P p);
}

class NoParameters extends Equatable {
  const NoParameters();
  @override
  List<Object?> get props => [];
}
