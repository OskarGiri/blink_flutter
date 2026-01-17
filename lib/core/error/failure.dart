import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Used when API call fails (login / register)
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({this.statusCode, required super.message});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}
