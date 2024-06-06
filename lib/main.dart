import 'package:egp/Constants.dart';
import 'package:egp/login/LoginPage.dart';
import 'package:egp/tracker/TrackerController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'login/LoginController.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Get.put(LoginController());
  Get.put(TrackerController());
  runApp(const EGPHome());
}

class EGPHome extends StatelessWidget {
  const EGPHome({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'e-GP',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: themeColor,
        canvasColor: whiteColor,
      ),
      home: const LoginPage(),
    );
  }
}

