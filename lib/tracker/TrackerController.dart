import 'package:egp/Constants.dart';
import 'package:egp/tracker/TrackerData.dart';
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
  var mod_trail_options = ["Automatik", "Manual"];
  var mod_trail_selectedValue = "Automatik".obs;

  var kaedah_trail_options = ["Kenderaan", "Berjalan"];
  var kaedah_trail_selectedValue = "Kenderaan".obs;


  var interval_options_kenderaan = ["30s", "1min", "1min 30s"];
  var interval_values_kenderaan = [30, 60, 90];

  var interval_options_berjalan = ["5min", "10min", "15min"];
  var interval_values_berjalan = [5, 10, 15];

  var interval_selectedValueS = "30s".obs;
  var interval_selectedValueM = "5min".obs;

  var negeri_options = ["Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan",
                        "Pahang", "Perak", "Pulau Pinang", "Perlis", "Selangor", "Terengganu",
                        "Wilayah Persekutuan"];

  var negeri_selectedValue = "Johor".obs;


  var nameValid = true.obs;
  var startValid = true.obs;
  var endValid = true.obs;

  var dataBox;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    openHive();
  }

  openHive() async {
    dataBox = await Hive.openBox("data");
  }

  List<String> getInterval(){
    if(kaedah_trail_selectedValue.value.contains("Kenderaan")){
      return interval_options_kenderaan;
    } else {
      return interval_options_berjalan;
    }
  }

  int getIntervalAmount(){
    return kaedah_trail_selectedValue.value.contains("Kenderaan") ? interval_values_kenderaan[interval_options_kenderaan.indexOf(interval_selectedValueS.value)] :
    interval_values_berjalan[interval_options_berjalan.indexOf(interval_selectedValueM.value)] * 60;
  }

  getSelectedValue(){
    return kaedah_trail_selectedValue.value.contains("Kenderaan") ? interval_selectedValueS : interval_selectedValueM;
  }

  setSelectedValue(String value) {
    kaedah_trail_selectedValue.value.contains("Kenderaan") ? interval_selectedValueS.value = value : interval_selectedValueM.value = value;
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
    var interval_type_id = 0;
    if(kaedah_trail_selectedValue.value.contains("Kenderaan")){
      interval = interval_values_kenderaan[interval_options_kenderaan.indexOf(interval_selectedValueS.value)];
      interval_type_id = 1;
    } else {
      interval = interval_values_berjalan[interval_options_berjalan.indexOf(interval_selectedValueM.value)];
      interval_type_id = 2;
    }

    var mod_trail_id = mod_trail_options.indexOf(mod_trail_selectedValue.value)+1;
    var kaedah_trail_id = kaedah_trail_options.indexOf(kaedah_trail_selectedValue.value)+1;
    var negeri_id = negeri_options.indexOf(negeri_selectedValue.value)+1;


    TrackerData trackerData = TrackerData(name: nameTextController.text, startPoint: startTextController.text, endPoint: endTextController.text,
        modTrailId: mod_trail_id, kaedahTrailId: kaedah_trail_id, negeriId: negeri_id,
        interval: interval, intervalTypeId: interval_type_id, locationPoints: userLocations);

    dataBox.put("${nameTextController.text}_data_${DateTime.now().microsecondsSinceEpoch}", trackerData.toJson());

    Get.snackbar("Success", "Data Saved Successfully");

  }
}