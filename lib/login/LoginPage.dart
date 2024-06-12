import 'package:egp/Constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import 'LoginController.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ic = TextFormField(
      controller: controller.icController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: const InputDecoration(
        hintStyle: TextStyle(color: Colors.white54),
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      ),
      style: const TextStyle(color: Colors.white70),
    );

    final password = TextFormField(
        controller: controller.passwordController,
        autofocus: false,
        obscureText: false,
        decoration: const InputDecoration(
          hintStyle: TextStyle(color: Colors.white54),
          hintText: 'Password',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        ),
        style: const TextStyle(color: Colors.white70)
    );

    final loginButton = SizedBox(
      width: Get.width / 2.5,
      child: ElevatedButton(
        onPressed: controller.checkLogin,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(15),
          backgroundColor: themeColor,
        ),

        child:  const Text('Log In',
            style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[themeColor, whiteColor]),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 120, width: 100,),
              Center(
                child: Card(
                  color: Colors.black45,
                  elevation:10,
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    width: Get.width * 0.85,
                    height: Get.width * 0.95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(height: 15.0),
                        Row(
                          children: [
                            Text(
                              "Welcome",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: Get.width / 100 * 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 15,),
                            Obx(()=> Visibility(visible: controller.progressVisible.value,child: const SpinKitChasingDots(color: Colors.red, size: 30,))),
                          ],
                        ),

                        const SizedBox(height: 30.0),
                        ic,
                        const SizedBox(height: 8.0),
                        password,
                        Spacer(),
                        loginButton,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
              Image.asset("assets/Logo512.png", height: 100,)
            ],
          ),
        ),
      ),
    );
  }
}

