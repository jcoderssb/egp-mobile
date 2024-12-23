import 'package:egp/global.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Constants.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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
      ..loadRequest(Uri.parse('https://egp.jcoders.online/api/mapmobile'), headers: {"Authorization": "Bearer $token"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
