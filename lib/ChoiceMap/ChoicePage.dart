import 'package:egp/ChoiceMap/TrackerList.dart';
import 'package:egp/tracker/TrackerPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants.dart';
import 'MapPage.dart';

class ChoicePage extends StatefulWidget {
  final String accessToken;

  ChoicePage({Key? key, required this.accessToken});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  late String accessToken;

  @override
  void initState() {
    super.initState();
    accessToken = widget.accessToken;
  }

  // i want to use access token in here!

  late final mapButton = SizedBox(
    width: Get.width * 0.8,
    child: ElevatedButton(
        onPressed: (){
          Get.to(()=> MapPage(accessToken: accessToken));
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: themeColor,
        ),

        child:  const Text('Aplikasi peta',
            style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold)),
  ),
  );

  final trackerButton = SizedBox(
    width: Get.width * 0.8,
    child: ElevatedButton(
      onPressed: (){
        Get.to(()=> const TrackerPage());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: themeColor,
      ),

      child:  const Text('Mulai Mode Jejak',
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    ),
  );

  final trackerList = SizedBox(
    width: Get.width * 0.8,
    child: ElevatedButton(
      onPressed: (){
        Get.to(()=> const TrackerList());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: themeColor,
      ),

      child:  const Text('Muat Naik Data',
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            mapButton,
            SizedBox(height: 50,),
            trackerButton,
            SizedBox(height: 50,),
            trackerList
          ],
        ),
      ),
    );
  }
}

