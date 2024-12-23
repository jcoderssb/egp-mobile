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
  var modTrailSelectedValue = "Automatik".obs;

  var kaedahTrailOptions = ["Kenderaan", "Berjalan"];
  var kaedahTrailSelectedValue = "Kenderaan".obs;


  var intervalOptionsKenderaan = ["30s", "1min", "1min 30s"];
  var intervalValuesKenderaan = [30, 60, 90];

  var intervalOptionsBerjalan = ["5min", "10min", "15min"];
  var intervalValuesBerjalan = [5, 10, 15];

  var intervalSelectedValueS = "30s".obs;
  var intervalSelectedValueM = "5min".obs;

  var negeriOptions = ["Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan",
                        "Pahang", "Perak", "Pulau Pinang", "Perlis", "Selangor", "Terengganu",
                        "Wilayah Persekutuan"];

  var negeriSelectedValue = "Johor".obs;


  var nameValid = true.obs;
  var startValid = true.obs;
  var endValid = true.obs;

  // ignore: prefer_typing_uninitialized_variables
  var dataBox;

  @override
  void onReady() {
    super.onReady();
    openHive();
  }

  openHive() async {
    dataBox = await Hive.openBox("data");
  }

  List<String> getInterval(){
    if(kaedahTrailSelectedValue.value.contains("Kenderaan")){
      return intervalOptionsKenderaan;
    } else {
      return intervalOptionsBerjalan;
    }
  }

  int getIntervalAmount(){
    return kaedahTrailSelectedValue.value.contains("Kenderaan") ? intervalValuesKenderaan[intervalOptionsKenderaan.indexOf(intervalSelectedValueS.value)] :
    intervalValuesBerjalan[intervalOptionsBerjalan.indexOf(intervalSelectedValueM.value)] * 60;
  }

  getSelectedValue(){
    return kaedahTrailSelectedValue.value.contains("Kenderaan") ? intervalSelectedValueS : intervalSelectedValueM;
  }

  setSelectedValue(String value) {
    kaedahTrailSelectedValue.value.contains("Kenderaan") ? intervalSelectedValueS.value = value : intervalSelectedValueM.value = value;
  }


  bool shouldEnableButton(){
    return nameTextController.text.isNotEmpty && startTextController.text.isNotEmpty && endTextController.text.isNotEmpty;
  }

  getColor(){
    return shouldEnableButton() ? whiteColor : Colors.grey;
  }
  // saves value to hive
  printSavedValue(){

    var interval = 0;
    var intervalTypeId = 0;
    if(kaedahTrailSelectedValue.value.contains("Kenderaan")){
      interval = intervalValuesKenderaan[intervalOptionsKenderaan.indexOf(intervalSelectedValueS.value)];
      intervalTypeId = 1;
    } else {
      interval = intervalValuesBerjalan[intervalOptionsBerjalan.indexOf(intervalSelectedValueM.value)];
      intervalTypeId = 2;
    }

    var modTrailId = modTrailOptions.indexOf(modTrailSelectedValue.value)+1;
    var kaedahTrailId = kaedahTrailOptions.indexOf(kaedahTrailSelectedValue.value)+1;
    var negeriId = negeriOptions.indexOf(negeriSelectedValue.value)+1;


    TrackerData trackerData = TrackerData(name: nameTextController.text, startPoint: startTextController.text, endPoint: endTextController.text,
        modTrailId: modTrailId, kaedahTrailId: kaedahTrailId, negeriId: negeriId,
        interval: interval, intervalTypeId: intervalTypeId, locationPoints: userLocations);

    dataBox.put("${nameTextController.text}_data_${DateTime.now().microsecondsSinceEpoch}", trackerData.toJson());

    Get.snackbar("Success", "Data Saved Successfully");

  }
}