import 'package:equatable/equatable.dart';
import '../../domain/entities/visit.dart';

abstract class VisitListState extends Equatable {
  const VisitListState();

  @override
  List<Object?> get props => [];
}

class VisitListInitial extends VisitListState {}

class VisitListLoading extends VisitListState {}

class VisitListLoaded extends VisitListState {
  final List<Visit> visits;

  const VisitListLoaded(this.visits);

  @override
  List<Object?> get props => [visits];
}

class VisitListError extends VisitListState {
  final String message;

  const VisitListError(this.message);

  @override
  List<Object?> get props => [message];
}

class VisitOperationSuccess extends VisitListState {}
