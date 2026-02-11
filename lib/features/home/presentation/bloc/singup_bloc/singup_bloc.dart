import 'package:bloc/bloc.dart';
import 'package:convo/core/di/injection.dart';
import 'package:convo/core/enum/status.dart';
import 'package:convo/core/model/user_model.dart';
import 'package:convo/core/payload/user_payload.dart';
import 'package:convo/features/home/domain_usecase/add_user_usecase.dart';
import 'package:convo/features/home/domain_usecase/get_user_usecase.dart';
import 'package:convo/features/home/presentation/pages/add_name_page.dart';
import 'package:convo/features/home/presentation/pages/home_page.dart';
import 'package:convo/features/home/presentation/pages/singup_page.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'singup_event.dart';
part 'singup_state.dart';
part 'singup_bloc.freezed.dart';

class SingupBloc extends Bloc<SingupEvent, SingupState> {
  final AddUserUsecase _addUserUsecase;
  final GetUserUsecase _getUserUsecase;
  SingupBloc({
    required AddUserUsecase adduserusecase,
    required GetUserUsecase getuserusecase,
  }) : _addUserUsecase = adduserusecase,
       _getUserUsecase = getuserusecase,
       super(const SingupState()) {
    on<_Init>(__Init);
    on<_Phone>(__Phone);
    on<_Name>(__Name);
    on<_NickName>(__NickName);
    on<_Lotti>(__Lotti);
    on<_Online>(__Online);
    on<_About>(__About);
    on<_Add>(__Add);
    on<_CheckNumber>(__checkNumber);
    on<_CheckUser>(__CheckUser);

  }
  Future<void> __Init(_Init event, Emitter<SingupState> emit) async {}

  Future<void> __Phone(_Phone event, Emitter<SingupState> emit) async {
    emit(state.copyWith(phone: event.value));
    print(state.phone);
  }

  Future<void> __Name(_Name event, Emitter<SingupState> emit) async {
    emit(state.copyWith(name: event.value));
  }

  Future<void> __NickName(_NickName event, Emitter<SingupState> emit) async {
    emit(state.copyWith(nickName: event.value));
  }

  Future<void> __About(_About event, Emitter<SingupState> emit) async {
    emit(state.copyWith(about: event.value));
  }

  Future<void> __Lotti(_Lotti event, Emitter<SingupState> emit) async {
    emit(state.copyWith(lotti: event.value));
  }

  Future<void> __Online(_Online event, Emitter<SingupState> emit) async {
    emit(state.copyWith(online: event.value));
  }

  Future<void> __Add(_Add event, Emitter<SingupState> emit) async {
    emit(state.copyWith(adduserStatus: Status.loading));

    final isAdded = await _addUserUsecase(
      UserPayload(
        name: state.name,
        nickName: state.nickName,
        phone: state.phone,
        about: state.about,
        lotti: state.lotti,
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
    await prefs.setString("phone", user.phone.toString());


    emit(
      state.copyWith(
        adduserStatus: Status.success,
        profile: user,
        name: user.name,
        nickName: user.nickName,
        phone: user.phone,
        about: user.about,
        lotti: user.lotti,
      ),
    );
  }

  Future<void> __checkNumber(_CheckNumber event, Emitter<SingupState> emit) async {
    emit(state.copyWith( checkNumberStatus: Status.loading));
    final user = await _getUserUsecase(phone: state.phone);

    print("test 33 $user");

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("id", user.id.toString());
      prefs.setString("phone", user.phone.toString());

      emit(
        state.copyWith(
          profile: user,
          name: user.name,
          nickName: user.nickName,
          phone: user.phone,
          about: user.about,
          lotti: user.lotti,
        ),
      );
    emit(state.copyWith( checkNumberStatus: Status.success));


      Navigator.pushReplacement(Injection.currentContext,MaterialPageRoute(builder: (_) => HomePage()),);
    } else {
    emit(state.copyWith( checkNumberStatus: Status.error));
      Navigator.pushReplacement(
        Injection.currentContext,
        MaterialPageRoute(builder: (_) => const AddNamePage(lotti: '')),
      );
    }
  }

    Future<void> __CheckUser(_CheckUser event, Emitter<SingupState> emit) async {
    emit(state.copyWith(checkuserStatus: Status.loading));

    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString("phone");
    final user = await _getUserUsecase(phone: phone.toString());
    if(user != null){
          emit(
        state.copyWith(
          profile: user,
          name: user.name,
          nickName: user.nickName,
          phone: user.phone,
          about: user.about,
          lotti: user.lotti,
        ),
      );
    emit(state.copyWith( checkuserStatus: Status.success));
      Navigator.pushReplacement(Injection.currentContext,MaterialPageRoute(builder: (_) => HomePage()),);
    }else{
    emit(state.copyWith( checkuserStatus: Status.error));
      Navigator.pushReplacement(Injection.currentContext,MaterialPageRoute(builder: (_) => SingupPage()),);
    }
  }
}
