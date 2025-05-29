import 'package:egp/global.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
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
      ..loadRequest(Uri.parse('https://myegp.forestry.gov.my/api/mobile/about'),
          headers: {"Authorization": "Bearer $token"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: controller),
    );
  }
}
