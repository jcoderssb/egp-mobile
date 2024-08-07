import 'package:egp/ChoiceMap/TrackerList.dart';
import 'package:egp/tracker/TrackerPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Constants.dart';
import 'MapPage.dart';
import 'DashboardIndexPage.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {

  final mapButton = SizedBox(
    width: Get.width * 0.8,
    child: ElevatedButton(
        onPressed: (){
          Get.to(()=> const MapPage());
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: themeColor,
        ),

        child:  const Text('Peta',
            style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold)),
    ),
  );

  final dashboardButton = SizedBox(
    width: Get.width * 0.8,
    child: ElevatedButton(
      onPressed: (){
        Get.to(()=> const DashboardIndexPage());
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(15),
        backgroundColor: themeColor,
      ),

      child:  const Text('Dashboard PSOH',
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

      child:  const Text('Trail Mode',
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
            dashboardButton,
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

