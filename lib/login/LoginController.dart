import 'dart:convert';
import 'package:egp/Constants.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:egp/tracker/TrackerPage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../ChoiceMap/ChoicePage.dart';
import 'LoginPage.dart';
class LoginController extends GetxController {

  var progressVisible = false.obs;
  var icController = TextEditingController();
  var passwordController = TextEditingController();

  var authBox;


  //admin@egp.com.my
  var loginUrl = "https://egp.jcoders.online/api/create-token";


  _initialScreen(isLoggedIn){
    if(!isLoggedIn){
      Get.offAll(()=> const LoginPage());
    }else{
      LoginController controller = Get.find();
      controller.passwordController.clear();
      Get.offAll(()=> ChoicePage(accessToken: ''));
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
    // TODO: implement onReady
    super.onReady();
    _initialScreen(false);
  }

  openHive() async {
    authBox = await Hive.openBox("auth");
  }

  void checkLogin(){
    // do the login here
    // icController.text = "mhasan341@gmail.com";
    // passwordController.text = "jJsB5WwGxTvXi7C!";

    // var validEmail = icController.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(icController.text);
    String passwordText = passwordController.text;
    //AuthController authController = Get.find();

    // if (validEmail && passwordText.isNotEmpty && passwordText.length >= 6){
      // do login
      showProgress();
      login(icController.text, passwordText);
    // } else{
    //   // if check
    //   Get.defaultDialog(
    //       title: "Error",
    //       middleText: "Enter email and password correctly",
    //       backgroundColor: Colors.white,
    //       titleStyle: const TextStyle(color: Colors.red),
    //       middleTextStyle: const TextStyle(color: Colors.black)
    //   );
    // }
  }

  void login(String ic, password) async {
    LoginController controller = Get.find();
    try{
      var url = Uri.parse(loginUrl);

      var response = await http.post(url, body: {'ic': ic, 'password': password});
      print(response.statusCode);
      print(response.reasonPhrase);

      if (response.statusCode == 200){

        Map jsonObject = json.decode(response.body);

        // if(jsonObject["status"]=="success") {
          // String token = jsonObject["access_token"];
          // String expiry = jsonObject["expires_at"];
          // await openHive();
          // authBox.put(TOKEN_KEY, token);
          // authBox.put(TOKEY_EXPIRE_KEY, expiry);

        var accessToken = jsonObject['access_token'];
        print(accessToken);

          moveToChoice(accessToken);
        // }

      } else {
          if (response.statusCode == 422) {
            Map jsonObject = json.decode(response.body);
            print(jsonObject["credentials"]);

          } else {
            Map jsonObject = json.decode(response.body);
            print(jsonObject["error"]);
          }

          Get.defaultDialog(
              title: "Error",
              middleText: "Enter email and password correctly",
              backgroundColor: Colors.white,
              titleStyle: const TextStyle(color: Colors.red),
              middleTextStyle: const TextStyle(color: Colors.black)
          );
      }

      controller.hideProgress();
      // moveToChoice();

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

  void moveToChoice(accessToken){

    Get.offAll(()=> ChoicePage(accessToken: accessToken));
  }

  void logOut() async {
    progressVisible.value = true;
    //await auth.signOut().then((value) => progressVisible.value = false);
  }
}