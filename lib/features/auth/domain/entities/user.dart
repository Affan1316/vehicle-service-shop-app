import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String role;
  final bool isActive;
  final String? customerId;
  final String? techId;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
    this.customerId,
    this.techId,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        role,
        isActive,
        customerId,
        techId,
      ];
}
