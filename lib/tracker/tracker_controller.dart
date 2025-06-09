import 'package:egp/Constants.dart';
import 'package:egp/tracker/tracker_data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class TrackerController extends GetxController {
  List<LocationPoints> userLocations = <LocationPoints>[].obs;

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

  var negeriOptions = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perak",
    "Pulau Pinang",
    "Perlis",
    "Selangor",
    "Terengganu",
    "Wilayah Persekutuan"
  ];

  var modTrailSelectedValue = RxnString();
  var kaedahTrailSelectedValue = RxnString();
  var intervalSelectedValueS = RxnString();
  var intervalSelectedValueM = RxnString();
  var negeriSelectedValue = RxnString();

  var nameValid = true.obs;
  var startValid = true.obs;
  var endValid = true.obs;

  // ignore: prefer_typing_uninitialized_variables
  late Box dataBox;
  // var dataBox;

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
    negeriSelectedValue.value = null;
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
        kaedahTrailSelectedValue.value != null &&
        negeriSelectedValue.value != null;
  }

  getColor() {
    return shouldEnableButton() ? whiteColor : Colors.grey;
  }

  // saves value to hive
  printSavedValue() {
    var interval = 0;
    var intervalTypeId = 0;

    if (kaedahTrailSelectedValue.value == "Kenderaan") {
      interval = intervalValuesKenderaan[
          intervalOptionsKenderaan.indexOf(intervalSelectedValueS.value!)];
      intervalTypeId = 1;
    } else {
      interval = intervalValuesBerjalan[
          intervalOptionsBerjalan.indexOf(intervalSelectedValueM.value!)];
      intervalTypeId = 2;
    }

    var modTrailId = modTrailOptions.indexOf(modTrailSelectedValue.value!) + 1;
    var kaedahTrailId =
        kaedahTrailOptions.indexOf(kaedahTrailSelectedValue.value!) + 1;
    var negeriId = negeriOptions.indexOf(negeriSelectedValue.value!) + 1;

    TrackerData trackerData = TrackerData(
        name: nameTextController.text,
        startPoint: startTextController.text,
        endPoint: endTextController.text,
        modTrailId: modTrailId,
        kaedahTrailId: kaedahTrailId,
        negeriId: negeriId,
        interval: interval,
        intervalTypeId: intervalTypeId,
        locationPoints: userLocations);

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
