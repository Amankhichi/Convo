import 'package:flutter/material.dart';

class LanguageManager extends ValueNotifier<Locale> {
  LanguageManager() : super(const Locale('en'));

  void setLocale(Locale newLocale) {
    if (value != newLocale) {
      value = newLocale;
    }
  }

  void switchLanguage(String languageCode) {
    setLocale(Locale(languageCode));
  }
}
