import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@singleton
class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('vi'));

  void setLocale(Locale locale) {
    emit(locale);
  }

  void toggleLanguage() {
    if (state.languageCode == 'vi') {
      emit(const Locale('en'));
    } else {
      emit(const Locale('vi'));
    }
  }
}
