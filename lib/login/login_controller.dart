import 'dart:convert';
import 'package:egp/Constants.dart';
import 'package:egp/global.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../ChoiceMap/choice_page.dart';
import 'login_page.dart';
class LoginController extends GetxController {

  var progressVisible = false.obs;
  var icController = TextEditingController();
  var passwordController = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables
  var authBox;


  //admin@egp.com.my
  var loginUrl = "https://egp.jcoders.online/api/create-token";


  _initialScreen(isLoggedIn){
    if(!isLoggedIn){
      Get.offAll(()=> const LoginPage());
    }else{
      LoginController controller = Get.find();
      controller.passwordController.clear();
      Get.offAll(()=> const ChoicePage());
    }
  }

  void showProgress(){
    progressVisible.value = true;
  }

  void hideProgress(){
    progressVisible.value = false;
  }
  @override
  void onReady() {
    super.onReady();
    _initialScreen(false);
  }

  openHive() async {
    authBox = await Hive.openBox("auth");
  }

  void checkLogin(){
    String passwordText = passwordController.text;
    showProgress();
    login(icController.text, passwordText);
  }

  void login(String ic, password) async {
    FocusManager.instance.primaryFocus?.unfocus();
    
    LoginController controller = Get.find();
    try{
      var url = Uri.parse(loginUrl);

      var response = await http.post(url, body: {'ic': ic, 'password': password});

      if (response.statusCode == 200){
        Map jsonObject = json.decode(response.body);
        if(jsonObject["status"]=="success") {
          String token = jsonObject["access_token"];
          String expiry = jsonObject["expires_at"];
          String u = jsonObject["u"];
          String nid = jsonObject["negeri_id"];
          await openHive();
          authBox.put(TOKEN_KEY, token);
          authBox.put(TOKEY_EXPIRE_KEY, expiry);

          UID = u;
          nID = nid;
          moveToChoice();
        }

      } else {
          Get.defaultDialog(
              title: "Error",
              middleText: "Enter ic and password correctly",
              backgroundColor: Colors.white,
              titleStyle: const TextStyle(color: Colors.red),
              middleTextStyle: const TextStyle(color: Colors.black)
          );
      }

      controller.hideProgress();

    }catch(e){
      controller.hideProgress();
      Get.snackbar("About Login", "Login message",
          backgroundColor: Colors.redAccent,
          snackPosition: SnackPosition.BOTTOM,
          titleText: const Text(
            "Login failed",
            style: TextStyle(
                color: Colors.white
            ),
          ),
          messageText: Text(
              e.toString(),
              style: const TextStyle(
                  color: Colors.white
              )
          )
      );
    }
  }

  void moveToChoice(){
    Get.offAll(()=> const ChoicePage());
  }

  void logOut() async {
    progressVisible.value = true;
  }
}