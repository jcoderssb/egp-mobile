import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  var currentLocale = const Locale('ms').obs; // Default to English

  void changeLocale(String languageCode) {
    currentLocale.value = Locale(languageCode);
    Get.updateLocale(currentLocale.value);
  }
}