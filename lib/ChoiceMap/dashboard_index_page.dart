import 'package:egp/global.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants.dart';
import 'package:egp/general_layout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardIndexPage extends StatefulWidget {
  const DashboardIndexPage({super.key});

  @override
  State<DashboardIndexPage> createState() => _DashboardIndexPageState();
}

class _DashboardIndexPageState extends State<DashboardIndexPage> {
  late WebViewController controller;

  @override
  void initState() {
    super.initState();

    var authBox = Hive.box("auth");

    var token = authBox.get(TOKEN_KEY);

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            controller.runJavaScript("myU='$UID'; myC='$nID'");
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
          Uri.parse(
              'https://myegp.forestry.gov.my/dashboards?isMobile=true&n=1'),
          headers: {"Authorization": "Bearer $token"});
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return GeneralScaffold(
      title: localization.choicepage_index_2,
      body: WebViewWidget(controller: controller),
    );
  }
}
