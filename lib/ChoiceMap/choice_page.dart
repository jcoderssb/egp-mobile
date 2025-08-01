import 'package:egp/global.dart';
import 'package:egp/ChoiceMap/tracker_list.dart';
import 'package:egp/locale/locale_controller.dart';
import 'package:egp/tracker/tracker_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants.dart';
import 'map_page.dart';
import 'dashboard_index_page.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:egp/login/login_page.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});
  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  void _openAboutOverlay(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.about_1),
          content: SingleChildScrollView(
            child: Text(
              localization.about_2,
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(localization.close),
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
    return Column(
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [themeColor, Color.fromARGB(255, 13, 138, 125)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 45, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: AutoSizeText(
            label,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: themeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout() {
    final localization = AppLocalizations.of(context)!;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            Text(
              localization.logout,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        content: Text(
          localization.logoutConfirm,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    localization.cancel,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _logout,
                  child: Text(localization.yes),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void _logout() async {
    final localization = AppLocalizations.of(context)!;

    Get.snackbar(
      localization.logout,
      localization.successLogout,
      backgroundColor: Color.fromARGB(200, 76, 175, 79),
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 2),
    );

    Get.offAll(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localization.appTitle,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            color: Color.fromARGB(255, 255, 255, 255),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(loginName),
              accountEmail: Text(''),
              currentAccountPicture: CircleAvatar(
                  // backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                  ),
              decoration: BoxDecoration(
                color: themeColor,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text(localization.choicepage_index_1),
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
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(localization.logout,
                  style: TextStyle(color: Colors.red)),
              onTap: _confirmLogout,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Version 2.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Top section
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: themeColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${localization.hi} $loginName ! 👋',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    localization.greeting,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      childAspectRatio: 0.8,
                      children: [
                        _buildGridButton(
                          icon: Icons.map,
                          label: localization.choicepage_index_1,
                          onPressed: () => Get.to(() => const MapPage()),
                        ),
                        _buildGridButton(
                          icon: Icons.dashboard,
                          label: localization.choicepage_index_2,
                          onPressed: () =>
                              Get.to(() => const DashboardIndexPage()),
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
                              icon: localeController
                                          .currentLocale.value.languageCode ==
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
                              icon: localeController
                                          .currentLocale.value.languageCode ==
                                      'ms'
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : const SizedBox(width: 16),
                              label: const Text('Melayu'),
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
          )
        ],
      ),
    );
  }
}
