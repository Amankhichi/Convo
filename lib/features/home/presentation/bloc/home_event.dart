part of 'home_bloc.dart';

abstract class HomeEvent {
  const factory HomeEvent.init() = _Init;
}

class _Init implements HomeEvent {
  const _Init();
}
