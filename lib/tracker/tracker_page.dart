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

  late Timer? mytimer;
  @override
  void initState() {
    super.initState();

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
    controller.isTracking.value = true;
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
    controller.isTracking.value = false;
    mytimer?.cancel();
    // print(
    //     'Timer State: ${mytimer != null ? "Active" : "Inactive/Manual Mode"}');
    // controller.debugPrintValues();
    controller.printSavedValue();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // final modalBottomSheetStyle = (BuildContext context) => Container(
  //       height: 300,
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         children: [
  //           Text(
  //             'Sila pilih',
  //             style: TextStyle(
  //               fontSize: 18,
  //               fontWeight: FontWeight.bold,
  //               color: Theme.of(context).primaryColor,
  //             ),
  //           ),
  //           const SizedBox(height: 16),
  //           Expanded(
  //             child: ListView.builder(
  //               itemCount: 0, // Will be overridden in each usage
  //               itemBuilder: (context, index) => ListTile(
  //                 title: Text(''),
  //                 trailing: Icon(Icons.check, color: Colors.green),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    // double width = 150;
    // double height = 150;
    return GeneralScaffold(
      title: localization.choicepage_index_3,
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
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
                                      controller:
                                          controller.nameTextController),
                                  HWMInputBox(
                                      hint: "Titik Mula",
                                      fieldValid: controller.startValid.value,
                                      controller:
                                          controller.startTextController),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Mod Trail"),
                                      TextButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 300,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Select Mod Trail',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount: controller
                                                            .modTrailOptions
                                                            .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          final option = controller
                                                                  .modTrailOptions[
                                                              index];
                                                          final isSelected =
                                                              controller
                                                                      .modTrailSelectedValue
                                                                      .value ==
                                                                  option;
                                                          return ListTile(
                                                            title: Text(
                                                              option,
                                                              style: TextStyle(
                                                                color: isSelected
                                                                    ? themeColor
                                                                    : Colors
                                                                        .black,
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            trailing: isSelected
                                                                ? Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        themeColor)
                                                                : null,
                                                            onTap: () {
                                                              controller
                                                                  .modTrailSelectedValue
                                                                  .value = option;
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.modTrailSelectedValue
                                                      .value ??
                                                  'Sila pilih',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(thickness: 1, color: Colors.grey),

                                // Kaedah Trail
                                Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Kaedah Trail"),
                                      TextButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 300,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Pilih Kaedah Trail',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount: controller
                                                            .kaedahTrailOptions
                                                            .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          final option = controller
                                                                  .kaedahTrailOptions[
                                                              index];
                                                          final isSelected =
                                                              controller
                                                                      .kaedahTrailSelectedValue
                                                                      .value ==
                                                                  option;
                                                          return ListTile(
                                                            title: Text(
                                                              option,
                                                              style: TextStyle(
                                                                color: isSelected
                                                                    ? themeColor
                                                                    : Colors
                                                                        .black,
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            trailing: isSelected
                                                                ? Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        themeColor)
                                                                : null,
                                                            onTap: () {
                                                              controller
                                                                  .kaedahTrailSelectedValue
                                                                  .value = option;
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller
                                                      .kaedahTrailSelectedValue
                                                      .value ??
                                                  'Sila pilih',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(thickness: 1, color: Colors.grey),

                                // Interval
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
                                            TextButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Container(
                                                      height: 300,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            'Pilih Interval',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),
                                                          Expanded(
                                                            child: ListView
                                                                .builder(
                                                              itemCount: controller
                                                                  .getInterval()
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                final interval =
                                                                    controller
                                                                            .getInterval()[
                                                                        index];
                                                                final isSelected =
                                                                    controller
                                                                            .getSelectedValue()
                                                                            .value ==
                                                                        interval;
                                                                return ListTile(
                                                                  title: Text(
                                                                    interval,
                                                                    style:
                                                                        TextStyle(
                                                                      color: isSelected
                                                                          ? themeColor
                                                                          : Colors
                                                                              .black,
                                                                      fontWeight: isSelected
                                                                          ? FontWeight
                                                                              .bold
                                                                          : FontWeight
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                  trailing: isSelected
                                                                      ? Icon(
                                                                          Icons
                                                                              .check,
                                                                          color:
                                                                              themeColor)
                                                                      : null,
                                                                  onTap: () {
                                                                    controller
                                                                        .setSelectedValue(
                                                                            interval);
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    controller
                                                            .getSelectedValue()
                                                            .value ??
                                                        'Interval',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.red),
                                                ],
                                              ),
                                            ),
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
                                Obx(
                                  () => Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Negeri"),
                                      TextButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Container(
                                                height: 300,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'Pilih Negeri',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        // color: Theme.of(context)
                                                        //     .primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount: controller
                                                            .negeriOptions
                                                            .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          final option = controller
                                                                  .negeriOptions[
                                                              index];
                                                          final isSelected =
                                                              controller
                                                                      .negeriSelectedValue
                                                                      .value ==
                                                                  option;
                                                          return ListTile(
                                                            title: Text(
                                                              option,
                                                              style: TextStyle(
                                                                color: isSelected
                                                                    ? themeColor
                                                                    : Colors
                                                                        .black,
                                                                fontWeight: isSelected
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                              ),
                                                            ),
                                                            trailing: isSelected
                                                                ? Icon(
                                                                    Icons.check,
                                                                    color:
                                                                        themeColor)
                                                                : null,
                                                            onTap: () {
                                                              controller
                                                                  .negeriSelectedValue
                                                                  .value = option;
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              controller.negeriSelectedValue
                                                      .value ??
                                                  'Sila pilih',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                    Theme.of(context).hintColor,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_drop_down,
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Divider(thickness: 1, color: Colors.grey),
                              ],
                            ),
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
          ),

          // Fixed bottom panel
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Stats row (points and coordinates)
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.location_pin,
                          value: '${controller.userLocations.length}',
                          label: 'Points',
                          color: controller.userLocations.isEmpty
                              ? Colors.red
                              : Colors.green,
                        ),
                        _buildStatItem(
                          icon: Icons.my_location,
                          value: '${controller.userLat}',
                          label: 'Latitude',
                        ),
                        _buildStatItem(
                          icon: Icons.my_location,
                          value: '${controller.userLon}',
                          label: 'Longitude',
                        ),
                      ],
                    )),

                const SizedBox(height: 16),

                //Button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Invisible spacer to maintain balance
                    Obx(() => controller.modTrailSelectedValue.value == "Manual"
                        ? const SizedBox(width: 60, height: 60)
                        : const SizedBox.shrink()),

                    // Tracking button
                    Obx(
                      () => GestureDetector(
                        onTap: () async {
                          if (controller.shouldEnableButton()) {
                            if (!controller.isTracking.value) {
                              await startTracker();
                            } else {
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
                          width: 80, // Adjust size as needed
                          height: 80,
                          decoration: BoxDecoration(
                            color: controller.isTracking.value
                                ? Colors.red
                                : themeColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Center(
                            child: Obx(() => Text(
                                  controller.isTracking.value
                                      ? 'STOP'
                                      : 'START',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ),

                    //Jejak Lokasi
                    Obx(() {
                      if (controller.modTrailSelectedValue.value == "Manual") {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => addManualLocationPoint(),
                            child: Container(
                              width: 60, // Slightly smaller than main button
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue, // Different color to distinguish
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.add_location_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } // build
}

// Helper widget for stat items
Widget _buildStatItem({
  required IconData icon,
  required String value,
  required String label,
  Color color = Colors.black,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}
