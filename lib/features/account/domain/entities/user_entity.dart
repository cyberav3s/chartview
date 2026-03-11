import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String plan;
  final DateTime createdAt;
  final List<String> followedSymbols;

  const UserEntity({
    required this.id, required this.email, required this.username,
    required this.displayName, this.avatarUrl, required this.plan,
    required this.createdAt, required this.followedSymbols,
  });

  bool get isPro => plan == 'pro' || plan == 'premium';

  @override
  List<Object?> get props => [id, email, username];
}