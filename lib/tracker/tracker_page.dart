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
  late Timer? mytimer;
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

  Future<void> startTracker() async {
    controller.userLocations.clear();

    _locationData = await location.getLocation();
    final lat = _locationData.latitude ?? 0;
    final lon = _locationData.longitude ?? 0;

    controller.userLat.value = lat;
    controller.userLon.value = lon;

    var userLocation = LocationPoints(lat: lat, lon: lon);
    controller.userLocations.add(userLocation);

    // Only start timer if NOT Manual mode
    if (controller.modTrailSelectedValue.value != "Manual") {
      mytimer = Timer.periodic(
        Duration(seconds: controller.getIntervalAmount()),
        (timer) async {
          _locationData = await location.getLocation();
          double lat = _locationData.latitude ?? 0;
          double lon = _locationData.longitude ?? 0;
          controller.userLat.value = lat;
          controller.userLon.value = lon;
          var newUserLocation = LocationPoints(lat: lat, lon: lon);
          controller.userLocations.add(newUserLocation);
        },
      );
    } else {
      mytimer = null;
    }
  }

  Future<void> addManualLocationPoint() async {
    try {
      final locationData = await location.getLocation();
      final lat = locationData.latitude ?? 0;
      final lon = locationData.longitude ?? 0;

      controller.userLocations.add(LocationPoints(lat: lat, lon: lon));

      controller.userLat.value = lat;
      controller.userLon.value = lon;
      // Show success snackbar
      Get.snackbar(
        'Point Added',
        'Location recorded (${controller.userLocations.length} total)',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    }
  }

  void stopTracker() {
    mytimer?.cancel();
    // print(
    //     'Timer State: ${mytimer != null ? "Active" : "Inactive/Manual Mode"}');
    // controller.debugPrintValues();
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
      body: RefreshIndicator(
        onRefresh: () async {
          controller.resetFields();
          setState(() {});
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      child: Column(
                        children: [
                          // Mod Trail
                          Obx(
                            () => Row(
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
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                  value: controller.modTrailSelectedValue.value,
                                  onChanged: (String? value) {
                                    controller.modTrailSelectedValue.value =
                                        value!;
                                  },
                                )),
                              ],
                            ),
                          ),

                          const Divider(thickness: 1, color: Colors.grey),

                          // Kaedah Trail
                          Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Kaedah Trail"),
                                  DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                    hint: Text(
                                      'Kaedah Trail',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    items: controller.kaedahTrailOptions
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    value: controller
                                        .kaedahTrailSelectedValue.value,
                                    onChanged: (String? value) {
                                      controller.kaedahTrailSelectedValue
                                          .value = value!;
                                    },
                                  )),
                                ],
                              )),
                          const Divider(thickness: 1, color: Colors.grey),

                          // Interval — reactive display based on modTrailSelectedValue
                          Obx(() {
                            if (controller.modTrailSelectedValue.value !=
                                "Manual") {
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Interval"),
                                      DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                        hint: const Text(
                                          'Interval',
                                          style: TextStyle(
                                              fontSize: 14, color: Colors.red),
                                        ),
                                        items: controller
                                            .getInterval()
                                            .map((String item) =>
                                                DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ))
                                            .toList(),
                                        value:
                                            controller.getSelectedValue().value,
                                        onChanged: (String? value) {
                                          controller.setSelectedValue(value!);
                                        },
                                      )),
                                    ],
                                  ),
                                  const Divider(
                                      thickness: 1, color: Colors.grey),
                                ],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }),

                          // Negeri
                          Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Negeri"),
                                  DropdownButtonHideUnderline(
                                      child: DropdownButton2<String>(
                                    hint: const Text(
                                      'Negeri',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.red),
                                    ),
                                    items: controller.negeriOptions
                                        .map((String item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ))
                                        .toList(),
                                    value: controller.negeriSelectedValue.value,
                                    onChanged: (String? value) {
                                      controller.negeriSelectedValue.value =
                                          value!;
                                    },
                                  )),
                                ],
                              )),
                          const Divider(thickness: 1, color: Colors.grey),
                        ],
                      ),
                    ),

                    //Location
                    Obx(() => Text(
                          'Points: ${controller.userLocations.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                    Obx(
                      () => Text(
                          "Koordinat: ${controller.userLat} ${controller.userLon}"),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //Jejak Lokasi
                    Obx(() {
                      if (controller.modTrailSelectedValue.value == "Manual") {
                        return ElevatedButton(
                          onPressed: () => addManualLocationPoint(),
                          child: Text("Jejak Lokasi"),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),

                    const SizedBox(
                      height: 20,
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
                                              color: themeColor.withValues(
                                                  alpha: 0.5),
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
                                        color:
                                            blackColor.withValues(alpha: 0.5),
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
                                            color: blackColor.withValues(
                                                alpha: 0.5),
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
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  _leftRightAnimationController.forward();
                                });
                                startTracker();
                              } else {
                                _playPauseAnimationController.reverse();
                                _topBottomAnimationController.stop();
                                _leftRightAnimationController.stop();

                                stopTracker();
                              }
                            } else {
                              Get.snackbar(
                                "Makluman",
                                "Sila isi semua ruangan dan pilihan dropdown terlebih dahulu.",
                                backgroundColor:
                                    const Color.fromARGB(200, 244, 67, 54),
                                colorText: Colors.white,
                                icon: const Icon(Icons.error_outline,
                                    color: Colors.white),
                                borderRadius: 10,
                                margin: const EdgeInsets.all(10),
                                duration: const Duration(seconds: 2),
                              );
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

                        // Status Indicator
                        Positioned(
                          bottom: -30,
                          left: 0,
                          right: 0,
                          child: Obx(() => Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: controller.userLocations.isEmpty
                                        ? Colors.red
                                        : Colors.green,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    controller.userLocations.isEmpty
                                        ? 'No points'
                                        : 'Points: ${controller.userLocations.length}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              )),
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
          ],
        ),
      ),
    );
  } // build
}
