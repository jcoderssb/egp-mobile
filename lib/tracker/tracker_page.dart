import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:egp/Constants.dart';
import 'package:egp/general_layout.dart';
import 'package:egp/helper/HWMInputBox.dart';
import 'package:egp/tracker/tracker_controller.dart';
import 'package:egp/tracker/tracker_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage>
    with TickerProviderStateMixin {
  TrackerController controller = Get.find();

  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  /// when playing, animation will be played
  bool playing = false;

  /// animation controller for the play pause button
  late AnimationController _playPauseAnimationController;

  /// animation & animation controller for the top-left and bottom-right bubbles
  late Animation<double> _topBottomAnimation;
  late AnimationController _topBottomAnimationController;

  /// animation & animation controller for the top-right and bottom-left bubbles
  late Animation<double> _leftRightAnimation;
  late AnimationController _leftRightAnimationController;

  late Timer mytimer;

  @override
  void initState() {
    super.initState();
    _playPauseAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _topBottomAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _leftRightAnimationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _topBottomAnimation = CurvedAnimation(
            parent: _topBottomAnimationController, curve: Curves.decelerate)
        .drive(Tween<double>(begin: 5, end: -5));
    _leftRightAnimation = CurvedAnimation(
            parent: _leftRightAnimationController, curve: Curves.easeInOut)
        .drive(Tween<double>(begin: 5, end: -5));

    _leftRightAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _leftRightAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _leftRightAnimationController.forward();
      }
    });

    _topBottomAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _topBottomAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _topBottomAnimationController.forward();
      }
    });

    initLocation();
  }

  initLocation() async {
    // Location related things
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.enableBackgroundMode(enable: true);
  }

  Future<void> startTimer() async {
    _locationData = await location.getLocation();
    var lat = _locationData.latitude ?? 0;
    var lon = _locationData.longitude ?? 0;

    controller.userLat.value = lat;
    controller.userLon.value = lon;

    var userLocation = LocationPoints(lat: lat, lon: lon);
    controller.userLocations.add(userLocation);

    mytimer = Timer.periodic(Duration(seconds: controller.getIntervalAmount()),
        (timer) async {
      _locationData = await location.getLocation();

      lat = _locationData.latitude ?? 0;
      lon = _locationData.longitude ?? 0;

      controller.userLat.value = lat;
      controller.userLon.value = lon;

      controller.userLocations.add(userLocation);
    });
  }

  void stopTimer() {
    mytimer.cancel();
    controller.printSavedValue();
  }

  @override
  void dispose() {
    _playPauseAnimationController.dispose();
    _topBottomAnimationController.dispose();
    _leftRightAnimationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    double width = 150;
    double height = 150;

    return GeneralScaffold(
      title: localization.choicepage_index_3,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              //Input
              Card(
                elevation: 4,
                color: const Color.fromARGB(255, 249, 255, 248),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HWMInputBox(
                          hint: "Nama Trail",
                          fieldValid: controller.nameValid.value,
                          controller: controller.nameTextController),
                      HWMInputBox(
                          hint: "Titik Mula",
                          fieldValid: controller.startValid.value,
                          controller: controller.startTextController),
                      HWMInputBox(
                          hint: "Titik Akhir",
                          fieldValid: controller.endValid.value,
                          controller: controller.endTextController),
                    ],
                  ),
                ),
              ),

              //Dropdown Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mod Trail"),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                          hint: Text(
                            'Mod Trail',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: controller.modTrailOptions
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: controller.modTrailSelectedValue.value,
                          onChanged: (String? value) {
                            setState(() {
                              controller.modTrailSelectedValue.value = value!;
                            });
                          },
                        )),
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Kaedah Trail"),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                          hint: Text(
                            'Mod Trail',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: controller.kaedahTrailOptions
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: controller.kaedahTrailSelectedValue.value,
                          onChanged: (String? value) {
                            setState(() {
                              controller.kaedahTrailSelectedValue.value =
                                  value!;
                            });
                          },
                        )),
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Interval"),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                          hint: const Text(
                            'Interval',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          items: controller
                              .getInterval()
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: controller.getSelectedValue().value,
                          onChanged: (String? value) {
                            setState(() {
                              controller.setSelectedValue(value!);
                            });
                          },
                        )),
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Negeri"),
                        DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                          hint: const Text(
                            'Negeri',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                          items: controller.negeriOptions
                              .map((String item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: controller.negeriSelectedValue.value,
                          onChanged: (String? value) {
                            setState(() {
                              controller.negeriSelectedValue.value = value!;
                            });
                          },
                        )),
                      ],
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              //Location
              Obx(
                () => Text(
                    "Location: ${controller.userLat} ${controller.userLon}"),
              ),

              const SizedBox(
                height: 50,
              ),

              //Button Play
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // bottom right dark pink
                  AnimatedBuilder(
                    animation: _topBottomAnimation,
                    builder: (context, _) {
                      return Positioned(
                        bottom: _topBottomAnimation.value,
                        right: _topBottomAnimation.value,
                        child: Container(
                          width: width * 0.9,
                          height: height * 0.9,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [themeColor, blackColor],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.5),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // top left pink
                  AnimatedBuilder(
                      animation: _topBottomAnimation,
                      builder: (context, _) {
                        return Positioned(
                          top: _topBottomAnimation.value,
                          left: _topBottomAnimation.value,
                          child: Container(
                            width: width * 0.9,
                            height: height * 0.9,
                            decoration: BoxDecoration(
                              color: themeColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [themeColor, blackColor],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: playing
                                  ? [
                                      BoxShadow(
                                        color:
                                            themeColor.withValues(alpha: 0.5),
                                        blurRadius: 10,
                                        spreadRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                        );
                      }), // light pink
                  // bottom left blue
                  AnimatedBuilder(
                      animation: _leftRightAnimation,
                      builder: (context, _) {
                        return Positioned(
                          bottom: _leftRightAnimation.value,
                          left: _leftRightAnimation.value,
                          child: Container(
                            width: width * 0.9,
                            height: height * 0.9,
                            decoration: BoxDecoration(
                              color: blackColor,
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [themeColor, blackColor],
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: blackColor.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  // top right dark blue
                  AnimatedBuilder(
                    animation: _leftRightAnimation,
                    builder: (context, _) {
                      return Positioned(
                        top: _leftRightAnimation.value,
                        right: _leftRightAnimation.value,
                        child: Container(
                          width: width * 0.9,
                          height: height * 0.9,
                          decoration: BoxDecoration(
                            color: blackColor,
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [themeColor, blackColor],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: playing
                                ? [
                                    BoxShadow(
                                      color: blackColor.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 5,
                                    ),
                                  ]
                                : [],
                          ),
                        ),
                      );
                    },
                  ),
                  // play button
                  GestureDetector(
                    onTap: () async {
                      if (controller.shouldEnableButton()) {
                        playing = !playing;

                        if (playing) {
                          _playPauseAnimationController.forward();
                          _topBottomAnimationController.forward();
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _leftRightAnimationController.forward();
                          });
                          startTimer();
                        } else {
                          _playPauseAnimationController.reverse();
                          _topBottomAnimationController.stop();
                          _leftRightAnimationController.stop();

                          stopTimer();
                        }
                      }
                    },
                    child: Container(
                      width: width,
                      height: height,
                      decoration: const BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _playPauseAnimationController,
                            size: 100,
                            color: whiteColor),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
    );
  } // build
}
