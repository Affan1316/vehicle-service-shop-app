import 'package:equatable/equatable.dart';
import '../../domain/entities/bay.dart';

abstract class BayState extends Equatable {
  const BayState();

  @override
  List<Object?> get props => [];
}

class BayInitial extends BayState {}

class BayLoading extends BayState {}

class BaysLoaded extends BayState {
  final List<Bay> bays;

  const BaysLoaded(this.bays);

  @override
  List<Object?> get props => [bays];
}

class BayOperationSuccess extends BayState {
  final Bay bay;

  const BayOperationSuccess(this.bay);

  @override
  List<Object?> get props => [bay];
}

class BayError extends BayState {
  final String message;

  const BayError(this.message);

  @override
  List<Object?> get props => [message];
}
