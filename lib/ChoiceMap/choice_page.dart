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
  void _openAboutOverlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About App'),
          content: const Text(
            'Untuk Pengguna iPhone atau sistem iOS, pergi ke App Store dan buat carian perkataan SPDGP.\n\n'
            'Untuk pengguna smartphone selain iPhone, yang menggunakan sistem operasi Android, pergi ke Play Store dan buat carian perkataan JPSM.',
            textAlign: TextAlign.justify,
            softWrap: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _logout() {
  //   // TODO: Implement logout logic
  //   Get.snackbar("Logout", "You have been logged out.");
  // }

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EGP Mobile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              color: Color.fromARGB(255, 255, 255, 255),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: _logout,
        //     color: Color.fromARGB(255, 255, 255, 255),
        //   ),
        // ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Ahmad bin Abu'),
              accountEmail: Text('Pentadbir'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
              ),
              decoration: BoxDecoration(
                color: themeColor, // your app theme color
              ),
            ),
            ListTile(
              leading: Icon(Icons.map),
              title: Text(
                localization.choicepage_index_1,
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const MapPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text(localization.choicepage_index_2),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const DashboardIndexPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.track_changes),
              title: Text(localization.choicepage_index_3),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const TrackerPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text(localization.choicepage_index_4),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => const TrackerList());
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [themeColor, whiteColor],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildGridButton(
                    icon: Icons.map,
                    label: localization.choicepage_index_1,
                    onPressed: () => Get.to(() => const MapPage()),
                  ),
                  _buildGridButton(
                    icon: Icons.dashboard,
                    label: localization.choicepage_index_2,
                    onPressed: () => Get.to(() => const DashboardIndexPage()),
                  ),
                  _buildGridButton(
                    icon: Icons.track_changes,
                    label: localization.choicepage_index_3,
                    onPressed: () => Get.to(() => const TrackerPage()),
                  ),
                  _buildGridButton(
                    icon: Icons.list,
                    label: localization.choicepage_index_4,
                    onPressed: () => Get.to(() => const TrackerList()),
                  ),
                  _buildGridButton(
                    icon: Icons.info_outline,
                    label: localization.choicepage_index_5,
                    onPressed: () => _openAboutOverlay(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        icon:
                            localeController.currentLocale.value.languageCode ==
                                    'en'
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : const SizedBox(width: 16),
                        label: const Text('English'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: localeController
                                      .currentLocale.value.languageCode ==
                                  'en'
                              ? Colors.white
                              : themeColor,
                          backgroundColor: localeController
                                      .currentLocale.value.languageCode ==
                                  'en'
                              ? themeColor
                              : Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          localeController.changeLocale('en');
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon:
                            localeController.currentLocale.value.languageCode ==
                                    'ms'
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : const SizedBox(width: 16),
                        label: const Text('Malay'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: localeController
                                      .currentLocale.value.languageCode ==
                                  'ms'
                              ? Colors.white
                              : themeColor,
                          backgroundColor: localeController
                                      .currentLocale.value.languageCode ==
                                  'ms'
                              ? themeColor
                              : Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          localeController.changeLocale('ms');
                        },
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
