import 'package:equatable/equatable.dart';
import '../../domain/entities/labor_entry.dart';

abstract class LaborState extends Equatable {
  const LaborState();

  @override
  List<Object?> get props => [];
}

class LaborInitial extends LaborState {}

class LaborLoading extends LaborState {}

class LaborEntriesLoaded extends LaborState {
  final List<LaborEntry> entries;

  const LaborEntriesLoaded(this.entries);

  @override
  List<Object?> get props => [entries];
}

class LaborOperationSuccess extends LaborState {
  final LaborEntry entry;

  const LaborOperationSuccess(this.entry);

  @override
  List<Object?> get props => [entry];
}

class LaborError extends LaborState {
  final String message;

  const LaborError(this.message);

  @override
  List<Object?> get props => [message];
}
