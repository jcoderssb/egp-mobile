import 'package:egp/Constants.dart';
import 'package:egp/tracker/tracker_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:egp/global.dart';

class TrackerController extends GetxController {
  // for app screen
  var userLat = 0.0.obs;
  var userLon = 0.0.obs;

  // Strings
  TextEditingController nameTextController = TextEditingController();
  TextEditingController startTextController = TextEditingController();
  TextEditingController endTextController = TextEditingController();

  // Numerics
  var modTrailOptions = ["Automatik", "Manual"];
  var kaedahTrailOptions = ["Kenderaan", "Berjalan"];
  var intervalOptionsKenderaan = ["30s", "1min", "1min 30s"];
  var intervalValuesKenderaan = [30, 60, 90];
  var intervalOptionsBerjalan = ["5min", "10min", "15min"];
  var intervalValuesBerjalan = [5, 10, 15];

  var modTrailSelectedValue = RxnString();
  var kaedahTrailSelectedValue = RxnString();
  var intervalSelectedValueS = RxnString();
  var intervalSelectedValueM = RxnString();

  var nameValid = true.obs;
  var startValid = true.obs;
  var endValid = true.obs;
  var isTracking = false.obs;
  var userLocations = <LocationPoints>[].obs;

  // ignore: prefer_typing_uninitialized_variables
  late Box dataBox;

  @override
  void onReady() {
    super.onReady();
    openHive();
  }

  @override
  void onClose() {
    nameTextController.dispose();
    startTextController.dispose();
    endTextController.dispose();
    super.onClose();
  }

  void resetFields() {
    nameTextController.clear();
    startTextController.clear();
    endTextController.clear();

    modTrailSelectedValue.value = null;
    kaedahTrailSelectedValue.value = null;
    intervalSelectedValueS.value = null;
    intervalSelectedValueM.value = null;

    userLat.value = 0.0;
    userLon.value = 0.0;
    userLocations.clear();

    nameValid.value = true;
    startValid.value = true;
    endValid.value = true;
  }

  openHive() async {
    dataBox = await Hive.openBox("data");
  }

  List<String> getInterval() {
    if (kaedahTrailSelectedValue.value == "Kenderaan") {
      return intervalOptionsKenderaan;
    } else if (kaedahTrailSelectedValue.value == "Berjalan") {
      return intervalOptionsBerjalan;
    } else {
      return [];
    }
  }

  int getIntervalAmount() {
    if (modTrailSelectedValue.value == "Manual") {
      return 30;
    }

    if (kaedahTrailSelectedValue.value == "Kenderaan") {
      if (intervalSelectedValueS.value == null) return 0;
      return intervalValuesKenderaan[
          intervalOptionsKenderaan.indexOf(intervalSelectedValueS.value!)];
    } else {
      if (intervalSelectedValueM.value == null) return 0;
      return intervalValuesBerjalan[
              intervalOptionsBerjalan.indexOf(intervalSelectedValueM.value!)] *
          60;
    }
  }

  RxnString getSelectedValue() {
    return kaedahTrailSelectedValue.value == "Kenderaan"
        ? intervalSelectedValueS
        : intervalSelectedValueM;
  }

  void setSelectedValue(String value) {
    if (kaedahTrailSelectedValue.value == "Kenderaan") {
      intervalSelectedValueS.value = value;
    } else {
      intervalSelectedValueM.value = value;
    }
  }

  bool shouldEnableButton() {
    return nameTextController.text.isNotEmpty &&
        startTextController.text.isNotEmpty &&
        endTextController.text.isNotEmpty &&
        modTrailSelectedValue.value != null &&
        kaedahTrailSelectedValue.value != null;
  }

  getColor() {
    return shouldEnableButton() ? whiteColor : Colors.grey;
  }

  void setModTrailSelection(String value) {
    modTrailSelectedValue.value = value;
  }

  // void debugPrintValues() {
  //   print('===== DEBUG TRACKER VALUES =====');
  //   print('Name: ${nameTextController.text}');
  //   print('Start Point: ${startTextController.text}');
  //   print('End Point: ${endTextController.text}');
  //   print('Mod Trail: ${modTrailSelectedValue.value}');
  //   print('Kaedah Trail: ${kaedahTrailSelectedValue.value}');
  //   print('Negeri: ${negeriSelectedValue.value}');

  //   // Print location points
  //   print('Location Points (${userLocations.length}):');
  //   for (var i = 0; i < userLocations.length; i++) {
  //     final point = userLocations[i];
  //     print('  Point ${i + 1}: Lat=${point.lat}, Lon=${point.lon}');
  //   }

  //   // Print calculated values
  //   print('Calculated Values:');
  //   print('  Interval: ${getIntervalAmount()} seconds');
  //   print('  Should Enable Button: ${shouldEnableButton()}');

  //   print('===============================');
  // }

  // saves value to hive
  printSavedValue() {
    if (userLocations.isEmpty) {
      Get.snackbar("Error", "No location points to save!");
      return; // Exit early if no data
    }

    var interval = 0;
    var intervalTypeId = 0;

    if (kaedahTrailSelectedValue.value == "Kenderaan") {
      intervalTypeId = 1;
      if (modTrailSelectedValue.value != "Manual") {
        interval = intervalValuesKenderaan[
            intervalOptionsKenderaan.indexOf(intervalSelectedValueS.value!)];
      }
    } else {
      intervalTypeId = 2;
      if (modTrailSelectedValue.value != "Manual") {
        interval = intervalValuesBerjalan[intervalOptionsBerjalan
                .indexOf(intervalSelectedValueM.value!)] *
            60;
      }
    }

    var modTrailId = modTrailOptions.indexOf(modTrailSelectedValue.value!) + 1;
    var kaedahTrailId =
        kaedahTrailOptions.indexOf(kaedahTrailSelectedValue.value!) + 1;
    var negeriId = int.tryParse(nID) ?? 0;

    TrackerData trackerData = TrackerData(
      name: nameTextController.text,
      startPoint: startTextController.text,
      endPoint: endTextController.text,
      modTrailId: modTrailId,
      kaedahTrailId: kaedahTrailId,
      negeriId: negeriId,
      interval: interval,
      intervalTypeId: intervalTypeId,
      locationPoints: userLocations,
    );

    dataBox.put(
        "${nameTextController.text}_data_${DateTime.now().microsecondsSinceEpoch}",
        trackerData.toJson());

    Get.snackbar(
      "Berjaya",
      "Data berjaya disimpan",
      backgroundColor: const Color.fromARGB(200, 76, 175, 79),
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 2),
    );

    resetFields();
  }
}
