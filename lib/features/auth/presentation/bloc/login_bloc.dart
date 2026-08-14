import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/notification_services.dart';
import '../../../../core/utils/status.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entity/user_entity.dart';
import '../../data/payload/user_payload.dart';
import '../../domain/usecase/get_user_usecase.dart';
import '../../domain/usecase/send_otp_usecase.dart';
import '../../domain/usecase/verify_otp_usecase.dart';
import '../../domain/usecase/complete_profile_usecase.dart';
import '../../../home/domain/usecase/update_online_status_usecase.dart';
import '../../domain/usecase/request_otp_usecase.dart';
import '../../data/model/request_otp_response.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/network/api_exceptions.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CompleteProfileUseCase _completeProfileUseCase;
  final GetUserUsecase _getUserUsecase;
  final UpdateOnlineStatusUseCase _updateOnlineStatusUseCase;
  final SendOtpUseCase _sendOtpUseCase;
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;

  LoginBloc({
    required CompleteProfileUseCase completeProfileUseCase,
    required GetUserUsecase getuserusecase,
    required UpdateOnlineStatusUseCase updateonlinestatususecase,
    required SendOtpUseCase sendOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required RequestOtpUseCase requestOtpUseCase,
  }) : _completeProfileUseCase = completeProfileUseCase,
       _getUserUsecase = getuserusecase,
       _updateOnlineStatusUseCase = updateonlinestatususecase,
       _sendOtpUseCase = sendOtpUseCase,
       _verifyOtpUseCase = verifyOtpUseCase,
       _requestOtpUseCase = requestOtpUseCase,
       super(const LoginState()) {
    on<_Init>(__Init);
    on<_Phone>(__Phone);
    on<_Name>(__Name);
    on<_NickName>(__NickName);
    on<_Lotti>(__Lotti);
    on<_Online>(__Online);
    on<_About>(__About);
    on<_Add>(__Add);
    on<_SendOtp>(_onSendOtp);
    on<_VerifyOtp>(_onVerifyOtp);
    on<_CheckNumber>(__checkNumber);
    on<_CheckUser>(__CheckUser);
    on<_SetOnline>(__SetOnline);
    on<RequestOtpEvent>(_onRequestOtp);
  }

  Future<void> __Init(_Init event, Emitter<LoginState> emit) async {}

  Future<void> __Phone(_Phone event, Emitter<LoginState> emit) async {
    emit(state.copyWith(phone: event.value));
  }

  Future<void> __Name(_Name event, Emitter<LoginState> emit) async {
    emit(state.copyWith(name: event.value));
  }

  Future<void> __NickName(_NickName event, Emitter<LoginState> emit) async {
    emit(state.copyWith(nickName: event.value));
  }

  Future<void> __About(_About event, Emitter<LoginState> emit) async {
    emit(state.copyWith(about: event.value));
  }

  Future<void> __Lotti(_Lotti event, Emitter<LoginState> emit) async {
    emit(state.copyWith(lotti: event.value));
  }

  Future<void> __Online(_Online event, Emitter<LoginState> emit) async {
    emit(state.copyWith(online: event.value));
  }

  Future<void> _onSendOtp(_SendOtp event, Emitter<LoginState> emit) async {
    emit(state.copyWith(sendOtpStatus: Status.loading));
    try {
      final success = await _sendOtpUseCase(state.phone);
      if (success) {
        emit(state.copyWith(sendOtpStatus: Status.success));
      } else {
        emit(state.copyWith(sendOtpStatus: Status.error));
      }
    } catch (e) {
      print("Send OTP Bloc Error: $e");
      emit(state.copyWith(sendOtpStatus: Status.error));
    }
  }

  Future<void> _onVerifyOtp(_VerifyOtp event, Emitter<LoginState> emit) async {
    emit(VerifyOtpLoading(
      phone: state.phone,
      name: state.name,
      nickName: state.nickName,
      about: state.about,
      lotti: state.lotti,
      online: state.online,
    ));
    try {
      final result = await _verifyOtpUseCase(
        countryCode: event.countryCode,
        mobileNumber: event.mobileNumber,
        otp: event.otp,
      );

      if (result.success) {
        emit(
          VerifyOtpSuccess(
            success: result.success,
            newUser: result.newUser,
            token: result.token,
            user: result.user,
            phone: event.mobileNumber,
            name: result.user?.name ?? state.name,
            nickName: result.user?.nickname ?? state.nickName,
            about: result.user?.about ?? state.about,
            lotti: result.user?.profile ?? state.lotti,
            online: result.user?.online ?? state.online,
          ),
        );
      } else {
        emit(
          VerifyOtpFailure(
            message: "Verification failed. Please try again.",
            phone: state.phone,
            name: state.name,
            nickName: state.nickName,
            about: state.about,
            lotti: state.lotti,
            online: state.online,
          ),
        );
      }
    } catch (e) {
      print("Verify OTP Bloc Error: $e");
      String errorMessage = "Verification failed. Please try again.";
      if (e is ApiException) {
        errorMessage = e.message;
      }
      emit(
        VerifyOtpFailure(
          message: errorMessage,
          phone: state.phone,
          name: state.name,
          nickName: state.nickName,
          about: state.about,
          lotti: state.lotti,
          online: state.online,
        ),
      );
    }
  }

  Future<void> __Add(_Add event, Emitter<LoginState> emit) async {
    emit(state.copyWith(adduserStatus: Status.loading));

    final isAdded = await _completeProfileUseCase(
      UserPayload(
        nickName: state.nickName,
        phone: state.phone,
        about: state.about,
        profile: state.lotti,
        online: true,
      ),
    );

    if (!isAdded) {
      emit(state.copyWith(adduserStatus: Status.error));
      return;
    }

    final user = await _getUserUsecase(phone: state.phone);

    if (user == null) {
      emit(state.copyWith(adduserStatus: Status.error));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", user.id.toString());
    await prefs.setString("phone", user.phone);

    emit(
      state.copyWith(
        adduserStatus: Status.success,
        profile: user,
        nickName: user.nickname,
        phone: user.phone,
        about: user.about,
        lotti: user.profile,
      ),
    );
  }

  Future<void> __checkNumber(
    _CheckNumber event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(checkNumberStatus: Status.loading));

    final user = await _getUserUsecase(phone: state.phone);

    if (user != null) {
      await NotificationService.showNotification(
        title: "Login Successful",
        body: "Welcome ${user.name}",
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("id", user.id.toString());
      await prefs.setString("phone", user.phone);

      emit(
        state.copyWith(
          profile: user,
          name: user.name,
          nickName: user.nickname,
          phone: user.phone,
          about: user.about,
          lotti: user.profile,
        ),
      );

      emit(state.copyWith(checkNumberStatus: Status.success));

      AppRouter.router.go('/home');
    } else {
      emit(state.copyWith(checkNumberStatus: Status.error));
      AppRouter.router.go('/add-name?lotti=');
    }
  }

  Future<void> __CheckUser(_CheckUser event, Emitter<LoginState> emit) async {
    emit(state.copyWith(checkuserStatus: Status.loading));
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phone");
    if (phone == null || phone.isEmpty) {
      emit(state.copyWith(checkuserStatus: Status.error));
      AppRouter.router.go('/login');
      return;
    }
    final user = await _getUserUsecase(phone: phone);
    if (user != null) {
      emit(
        state.copyWith(
          profile: user,
          name: user.name,
          nickName: user.nickname,
          phone: user.phone,
          about: user.about,
          lotti: user.profile,
        ),
      );
      emit(state.copyWith(checkuserStatus: Status.success));
      AppRouter.router.go('/home');
    } else {
      emit(state.copyWith(checkuserStatus: Status.error));
      AppRouter.router.go('/login');
    }
  }

  Future<void> __SetOnline(_SetOnline event, Emitter<LoginState> emit) async {
    final updatedUser = await _updateOnlineStatusUseCase(
      id: event.userId,
      online: event.online,
    );

    emit(state.copyWith(profile: updatedUser, online: updatedUser.online));
  }

  Future<void> _onRequestOtp(RequestOtpEvent event, Emitter<LoginState> emit) async {
    emit(RequestOtpLoading(
      phone: state.phone,
      name: state.name,
      nickName: state.nickName,
      about: state.about,
      lotti: state.lotti,
      online: state.online,
    ));

    final result = await _requestOtpUseCase(
      countryCode: event.countryCode,
      mobileNumber: event.mobileNumber,
    );

    switch (result) {
      case Success(:final data):
        emit(RequestOtpSuccess(
          response: data,
          phone: state.phone,
          name: state.name,
          nickName: state.nickName,
          about: state.about,
          lotti: state.lotti,
          online: state.online,
        ));
      case FailureResult(:final message):
        emit(RequestOtpFailure(
          message: message,
          phone: state.phone,
          name: state.name,
          nickName: state.nickName,
          about: state.about,
          lotti: state.lotti,
          online: state.online,
        ));
    }
  }
}

