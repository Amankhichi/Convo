part of 'contact_bloc.dart';

abstract class ContactEvent {
  const factory ContactEvent.init() = _Init;
}

class _Init implements ContactEvent {
  const _Init();
}
