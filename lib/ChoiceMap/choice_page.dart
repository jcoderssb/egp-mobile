import 'package:egp/ChoiceMap/tracker_list.dart';
import 'package:egp/locale/locale_controller.dart';
import 'package:egp/tracker/tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart';
import 'map_page.dart';
import 'dashboard_index_page.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final localization = AppLocalizations.of(context);

    return Scaffold(
      body: SizedBox(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const MapPage());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: themeColor,
                ),
                child: Text(localization!.choicepage_index_1,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: Get.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const DashboardIndexPage());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: themeColor,
                ),
                child: Text(localization.choicepage_index_2,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: Get.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const TrackerPage());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: themeColor,
                ),
                child: Text(localization.choicepage_index_3,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: Get.width * 0.8,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => const TrackerList());
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: themeColor,
                ),
                child: Text(localization.choicepage_index_4,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                localeController.changeLocale('en'); // Switch to English
              },
              child: const Text('English'),
            ),
            ElevatedButton(
              onPressed: () {
                localeController.changeLocale('ms'); // Switch to Spanish
              },
              child: const Text('Malay'),
            ),
          ],
        ),
      ),
    );
  }
}
