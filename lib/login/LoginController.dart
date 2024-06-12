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
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var authBox;


  //admin@egp.com.my
  var loginUrl = "http://egp.jcoders.online/api/create-token";


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
    // TODO: implement onReady
    super.onReady();
    _initialScreen(false);
  }

  openHive() async {
    authBox = await Hive.openBox("auth");
  }

  void checkLogin(){
    // do the login here
    // emailController.text = "mhasan341@gmail.com";
    // passwordController.text = "jJsB5WwGxTvXi7C!";

    // var validEmail = emailController.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
    //     .hasMatch(emailController.text);
    String passwordText = passwordController.text;
    //AuthController authController = Get.find();

    // if (validEmail && passwordText.isNotEmpty && passwordText.length >= 6){
      // do login
      showProgress();
      login(emailController.text, passwordText);
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

      if (response.statusCode == 200){
        Map jsonObject = json.decode(response.body);
        if(jsonObject["status"]=="success") {
          String token = jsonObject["access_token"];
          String expiry = jsonObject["expires_at"];
          await openHive();
          authBox.put(TOKEN_KEY, token);
          authBox.put(TOKEY_EXPIRE_KEY, expiry);

          moveToChoice();
        }

      } else {
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

  void moveToChoice(){
    Get.offAll(()=> const ChoicePage());
  }

  void logOut() async {
    progressVisible.value = true;
    //await auth.signOut().then((value) => progressVisible.value = false);
  }
}