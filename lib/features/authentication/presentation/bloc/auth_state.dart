import 'package:convo/features/authentication/data/models/auth_response_model.dart';
import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String countryCode;
  final String phoneNumber;

  const OtpSentSuccess({required this.countryCode, required this.phoneNumber});

  @override
  List<Object?> get props => [countryCode, phoneNumber];
}

class OtpVerifiedSuccess extends AuthState {
  final VerifyOtpResponseModel response;

  const OtpVerifiedSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class AuthenticatedState extends AuthState {}

class UnauthenticatedState extends AuthState {}

class LoggedOutState extends AuthState {}

class AccountDeletedSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
