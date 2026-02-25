import 'package:equatable/equatable.dart';

class ResetTokenEntity extends Equatable {
  final String resetToken;

  const ResetTokenEntity({required this.resetToken});

  @override
  List<Object?> get props => [resetToken];
}
