import 'package:egp/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ic = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller.icController,
        decoration: InputDecoration(
          hintText: 'ID Pengguna',
          prefixIcon: const Icon(Icons.person),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color.fromRGBO(15, 160, 145, 1)),
          ),
        ),
      ),
    );

    final password = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Obx(
        () => TextFormField(
          obscureText: controller.isPasswordHidden.value,
          controller: controller.passwordController,
          decoration: InputDecoration(
            hintText: 'Kata Laluan',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordHidden.value
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
              onPressed: () {
                controller.isPasswordHidden.value =
                    !controller.isPasswordHidden.value;
              },
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color.fromRGBO(15, 160, 145, 1)),
            ),
          ),
        ),
      ),
    );

    final loginButton = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: SizedBox(
        width: double.infinity, // Full width inside the padding
        child: ElevatedButton(
          onPressed: controller.checkLogin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20.0),
            backgroundColor: themeColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0, // optional: remove elevation if you want flat look
          ),
          child: const Text(
            'Log Masuk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg2.jpeg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.5), BlendMode.colorBurn),
        ),
      ),
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Icon
                    Image.asset(
                      "assets/Logo512.png",
                      height: 100,
                    ),

                    const SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: Get.width * 0.7,
                      child: Text(
                        "SISTEM E-GEOSPATIAL PERHUTANAN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Get.width / 100 * 6,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                    // SizedBox(
                    //   width: Get.width * 0.7,
                    //   child: Text(
                    //     "EGP.JCODERS.ONLINE",
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //       fontSize: Get.width / 100 * 3,
                    //       fontWeight: FontWeight.bold,
                    //       color: const Color.fromARGB(255, 255, 217, 0),
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(
                      height: 60.0,
                    ),

                    const Text('Log Masuk Akaun Anda',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                        )),

                    const SizedBox(
                      height: 20.0,
                    ),

                    ic,

                    const SizedBox(
                      height: 20.0,
                    ),

                    password,

                    const SizedBox(
                      height: 20.0,
                    ),

                    loginButton,

                    const SizedBox(
                      height: 100.0,
                    ),

                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 20),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "DATA TERHAD",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Get.width / 100 * 3,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Spinner overlay
          Obx(() {
            return controller.progressVisible.value
                ? Container(
                    color:
                        Colors.black.withValues(alpha: 0.5), // dim background
                    child: const Center(
                      child: SpinKitChasingDots(
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
