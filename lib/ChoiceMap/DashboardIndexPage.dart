import 'package:egp/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Constants.dart';

class DashboardIndexPage extends StatefulWidget {
  const DashboardIndexPage({super.key});

  @override
  State<DashboardIndexPage> createState() => _DashboardIndexPageState();
}

class _DashboardIndexPageState extends State<DashboardIndexPage> {

  late WebViewController controller;

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
          onPageStarted: (String url) {

          },
          onPageFinished: (String url) {
            controller.runJavaScript('myU="' + UID + '"; myC="' + nID + '"');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://egp.jcoders.online/api/mobile/dashboards'), headers: {"Authorization": "Bearer $token"});
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}