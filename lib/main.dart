import 'package:egp/constants.dart';
import 'package:egp/login/login_page.dart';
import 'package:egp/locale/locale_controller.dart';
import 'package:egp/tracker/tracker_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login/login_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Get.put(LoginController());
  Get.put(TrackerController());
  Get.put(LocaleController());
  runApp(const EGPHome());
}

class EGPHome extends StatelessWidget {
  const EGPHome({super.key});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'e-GP',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeController.currentLocale.value, // Dynamic locale
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: themeColor,
        canvasColor: whiteColor,
      ),
      home: const LoginPage(),
    );
  }
}
