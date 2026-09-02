import 'package:convo/core/constants/storage_keys.dart';
import 'package:convo/core/presence/presence_manager.dart';
import 'package:convo/core/storage/local_storage.dart';
import 'package:convo/features/authentication/domain/usecases/delete_account_usecase.dart';
import 'package:convo/features/authentication/domain/usecases/request_otp_usecase.dart';
import 'package:convo/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_event.dart';
import 'package:convo/features/authentication/presentation/bloc/auth_state.dart';
import 'package:convo/injection/dependency_injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final LocalStorage _localStorage;

  AuthBloc({
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required LocalStorage localStorage,
  })  : _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _deleteAccountUseCase = deleteAccountUseCase,
        _localStorage = localStorage,
        super(AuthInitial()) {
    on<RequestOtpEvent>(_onRequestOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthSessionEvent>(_onCheckAuthSession);
    on<LogoutEvent>(_onLogout);
    on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _requestOtpUseCase.execute(event.countryCode, event.phoneNumber);
      if (success) {
        emit(OtpSentSuccess(countryCode: event.countryCode, phoneNumber: event.phoneNumber));
      } else {
        emit(const AuthError("Failed to send OTP. Please check your number."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _verifyOtpUseCase.execute(
        event.countryCode,
        event.phoneNumber,
        event.otp,
      );
      if (response.token.isNotEmpty) {
        await _localStorage.setString(StorageKeys.jwtToken, response.token);
        await _localStorage.setString(StorageKeys.phone, "${event.countryCode}${event.phoneNumber}");
        if (response.user != null) {
          await _localStorage.setString(StorageKeys.userId, response.user!.id.toString());
          await _localStorage.setString(StorageKeys.name, response.user!.name);
          await _localStorage.setString(StorageKeys.about, response.user!.about);
          await _localStorage.setString(StorageKeys.profileImage, response.user!.profileImage);
        }
        sl<PresenceManager>().start();
        emit(OtpVerifiedSuccess(response));
      } else {
        emit(const AuthError("Authentication failed: Missing token."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuthSession(CheckAuthSessionEvent event, Emitter<AuthState> emit) async {
    final token = _localStorage.getString(StorageKeys.jwtToken);
    if (token != null && token.isNotEmpty) {
      sl<PresenceManager>().start();
      emit(AuthenticatedState());
    } else {
      sl<PresenceManager>().stop();
      emit(UnauthenticatedState());
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    sl<PresenceManager>().stop();
    await _localStorage.clear();
    emit(LoggedOutState());
  }

  Future<void> _onDeleteAccount(DeleteAccountEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _deleteAccountUseCase.execute();
      if (success) {
        sl<PresenceManager>().stop();
        await _localStorage.clear();
        emit(AccountDeletedSuccess());
      } else {
        emit(const AuthError("Failed to delete account. Please try again."));
      }
    } catch (e) {
      emit(AuthError("Failed to delete account: ${e.toString()}"));
    }
  }
}
