import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class RequestOtpEvent extends AuthEvent {
  final String countryCode;
  final String phoneNumber;

  const RequestOtpEvent({required this.countryCode, required this.phoneNumber});

  @override
  List<Object?> get props => [countryCode, phoneNumber];
}

class VerifyOtpEvent extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  final String otp;

  const VerifyOtpEvent({
    required this.countryCode,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [countryCode, phoneNumber, otp];
}

class CheckAuthSessionEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class DeleteAccountEvent extends AuthEvent {}
