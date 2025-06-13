import 'dart:async';
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
    final localization = AppLocalizations.of(context)!;
    try {
      final locationData = await location.getLocation();
      final lat = locationData.latitude ?? 0;
      final lon = locationData.longitude ?? 0;

      controller.userLocations.add(LocationPoints(lat: lat, lon: lon));
      controller.userLat.value = lat;
      controller.userLon.value = lon;

      Get.snackbar(
        'Point Added',
        'Location recorded (${controller.userLocations.length} total)',
        backgroundColor: Colors.green[400],
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        localization.error,
        'Failed to get location',
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
    }
  }

  Future<void> stopTracker() async {
    final localization = AppLocalizations.of(context)!;
    bool? shouldStop = await showModalBottomSheet<bool>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${localization.finish}  ${localization.trail}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localization.confirm_finish_track,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(localization.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(localization.finish),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (shouldStop ?? false) {
      controller.isTracking.value = false;
      mytimer?.cancel();
      // controller.debugPrintValues();
      controller.printSavedValue();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  IconData _getKaedahTrailIcon(String? value) {
    if (value == null) return Icons.directions_walk;
    return value.toLowerCase().contains('kenderaan')
        ? Icons.directions_car
        : Icons.directions_walk;
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
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
                          //Input Section
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                HWMInputBox(
                                    hint:
                                        localization.tracker_page_placeholder_1,
                                    fieldValid: controller.nameValid.value,
                                    controller: controller.nameTextController),
                                HWMInputBox(
                                    hint:
                                        localization.tracker_page_placeholder_2,
                                    fieldValid: controller.startValid.value,
                                    controller: controller.startTextController),
                                HWMInputBox(
                                    hint:
                                        localization.tracker_page_placeholder_3,
                                    fieldValid: controller.endValid.value,
                                    controller: controller.endTextController),
                              ],
                            ),
                          ),

                          //Dropdown Section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Mod Trail Dropdown
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Obx(
                                          () => TextButton(
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
                                                          localization
                                                              .choose_trail_mode,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            itemCount: controller
                                                                .modTrailOptions
                                                                .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              final option =
                                                                  controller
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
                                            style: TextButton.styleFrom(
                                              backgroundColor: controller
                                                          .modTrailSelectedValue
                                                          .value !=
                                                      null
                                                  ? Colors.green[100]
                                                  : Colors.grey[100],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.track_changes,
                                                    size: 40,
                                                    color: controller
                                                                    .modTrailSelectedValue
                                                                    .value !=
                                                                null &&
                                                            controller
                                                                .modTrailSelectedValue
                                                                .value!
                                                                .isNotEmpty
                                                        ? themeColor
                                                        : Colors.grey[500]),
                                                const SizedBox(height: 4),
                                                Text(
                                                  controller
                                                          .modTrailSelectedValue
                                                          .value ??
                                                      localization.trail_mode,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Vertical divider
                                    Container(
                                      width: 1,
                                      height: 60,
                                      color: Colors.grey[300],
                                    ),

                                    // Kaedah Trail Dropdown
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: Obx(
                                          () => TextButton(
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
                                                          localization
                                                              .choose_method_trail,
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 16),
                                                        Expanded(
                                                          child:
                                                              ListView.builder(
                                                            itemCount: controller
                                                                .kaedahTrailOptions
                                                                .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int index) {
                                                              final option =
                                                                  controller
                                                                          .kaedahTrailOptions[
                                                                      index];
                                                              final isSelected =
                                                                  controller
                                                                          .kaedahTrailSelectedValue
                                                                          .value ==
                                                                      option;
                                                              // Determine icon based on option
                                                              final icon = option
                                                                      .toLowerCase()
                                                                      .contains(
                                                                          'kenderaan')
                                                                  ? Icons
                                                                      .directions_car
                                                                  : Icons
                                                                      .directions_walk;

                                                              return ListTile(
                                                                leading: Icon(
                                                                    icon,
                                                                    color: isSelected
                                                                        ? themeColor
                                                                        : Colors
                                                                            .grey),
                                                                title: Text(
                                                                  option,
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
                                            style: TextButton.styleFrom(
                                              backgroundColor: controller
                                                          .kaedahTrailSelectedValue
                                                          .value !=
                                                      null
                                                  ? Colors.green[100]
                                                  : Colors.grey[100],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12.0),
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Dynamic icon based on selected value
                                                Icon(
                                                  _getKaedahTrailIcon(controller
                                                      .kaedahTrailSelectedValue
                                                      .value),
                                                  size: 40,
                                                  color: controller
                                                                  .kaedahTrailSelectedValue
                                                                  .value !=
                                                              null &&
                                                          controller
                                                              .kaedahTrailSelectedValue
                                                              .value!
                                                              .isNotEmpty
                                                      ? themeColor
                                                      : Colors.grey[500],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  controller
                                                          .kaedahTrailSelectedValue
                                                          .value ??
                                                      localization.method_trail,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .hintColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Vertical divider
                                    Obx(() {
                                      if (controller
                                              .modTrailSelectedValue.value !=
                                          "Manual") {
                                        return Container(
                                          width: 1,
                                          height: 60,
                                          color: Colors.grey[300],
                                        );
                                      } else {
                                        return const SizedBox(width: 0);
                                      }
                                    }),

                                    // Interval Dropdown
                                    Obx(() {
                                      if (controller
                                              .modTrailSelectedValue.value !=
                                          "Manual") {
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: TextButton(
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
                                                            localization
                                                                .choose_interval,
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
                                              style: TextButton.styleFrom(
                                                backgroundColor: controller
                                                            .getSelectedValue()
                                                            .value !=
                                                        null
                                                    ? Colors.green[100]
                                                    : Colors.grey[100],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.access_time_filled,
                                                      size: 40,
                                                      color: controller
                                                                      .getSelectedValue()
                                                                      .value !=
                                                                  null &&
                                                              controller
                                                                  .getSelectedValue()
                                                                  .value!
                                                                  .isNotEmpty
                                                          ? themeColor
                                                          : Colors.grey[500]),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    controller
                                                            .getSelectedValue()
                                                            .value ??
                                                        localization.interval,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox(width: 0);
                                      }
                                    }),
                                  ],
                                ),
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
                              await stopTracker();
                            }
                          } else {
                            Get.snackbar(
                              localization.attention,
                              localization.fill_all,
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
                                      ? localization.finish
                                      : localization.start,
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
                            onTap: controller.isTracking.value
                                ? () => addManualLocationPoint()
                                : () {
                                    Get.snackbar(
                                      localization.attention,
                                      localization.track_first,
                                      backgroundColor: Colors.orange[400],
                                      colorText: Colors.white,
                                    );
                                  },
                            child: Container(
                              width: 60, // Slightly smaller than main button
                              height: 60,
                              decoration: BoxDecoration(
                                color: controller.isTracking.value
                                    ? Colors.blue
                                    : Colors.grey,
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
