import 'dart:convert';
import 'package:egp/constants.dart';
import 'package:egp/network/api_endpoints.dart';
import 'package:egp/tracker/tracker_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:egp/general_layout.dart';
import 'package:http/http.dart' as http;
import 'package:egp/flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class TrackerList extends StatefulWidget {
  const TrackerList({super.key});

  @override
  State<TrackerList> createState() => _TrackerListState();
}

class _TrackerListState extends State<TrackerList> {
  var dataBox = Hive.box("data");
  var authBox = Hive.box("auth");

  Set<int> uploadingIndexes = {};
  Set<int> uploadedIndexes = {};

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<dynamic> get filteredTrackers {
    if (searchQuery.isEmpty) {
      return dataBox.values.toList();
    }
    return dataBox.values.where((trackerJson) {
      final trackerData = jsonDecode(jsonEncode(trackerJson));
      final trackerObj = TrackerData.fromJson(trackerData);
      return trackerObj.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          trackerObj.startPoint
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          trackerObj.endPoint
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          DateFormat('yyyy-MM-dd')
              .format(trackerObj.trackingEndTime)
              .contains(searchQuery) ||
          DateFormat('hh:mma')
              .format(trackerObj.trackingEndTime)
              .contains(searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Preview detail item
  void _showTrackerDetails(BuildContext context, TrackerData trackerObj) {
    final localization = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height:
            MediaQuery.of(context).size.height * 0.8, // 80% of screen height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with title and close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trackerObj.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Divider line
            Divider(height: 1),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // First row
                            _buildDetailSection(
                              children: [
                                _buildDetailItem(
                                  label:
                                      localization.tracker_page_placeholder_2,
                                  value: trackerObj.startPoint,
                                ),
                                _buildDetailItem(
                                  label:
                                      localization.tracker_page_placeholder_3,
                                  value: trackerObj.endPoint,
                                ),
                              ],
                            ),

                            Divider(height: 20),

                            // Second row
                            _buildDetailSection(
                              children: [
                                _buildDetailItem(
                                  label: localization.tracker_page_label_1,
                                  value: trackerObj.modTrailOptions,
                                ),
                                _buildDetailItem(
                                  label: localization.tracker_page_label_2,
                                  value: trackerObj.kaedahTrailOptions,
                                ),
                                if (trackerObj.intervalValue != 'Tiada')
                                  _buildDetailItem(
                                    label: localization.interval,
                                    value: trackerObj.intervalValue,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                        "Location Points: ${trackerObj.locationPoints.length} points",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...trackerObj.locationPoints.map(
                      (point) => Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text("📍 Lat: ${point.lat}, Lng: ${point.lon}"),
                      ),
                    ),
                    SizedBox(height: 20), // Extra space at bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent detail rows
  Widget _buildDetailSection({required List<Widget> children}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  Widget _buildDetailItem({required String label, required String value}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Delete all item
  Future<void> _showDeleteConfirmation() async {
    final localization = AppLocalizations.of(context)!;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localization.delete,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              localization.confirm_delete,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localization.cancel,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteAllData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localization.delete,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAllData() async {
    final localization = AppLocalizations.of(context)!;
    await dataBox.clear();
    setState(() {
      uploadedIndexes.clear();
    });
    Get.snackbar(
      localization.success,
      localization.success_delete,
      backgroundColor: Color.fromARGB(200, 76, 175, 79),
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 2),
    );
  }

// Delete single item
  Future<void> _showDeleteConfirmationForItem(
      int index, TrackerData trackerObj) async {
    final localization = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localization.delete,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                children: [
                  TextSpan(text: "${localization.confirm_delete_item} "),
                  TextSpan(
                    text: trackerObj.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(text: "?"),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localization.cancel,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteSingleData(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      localization.delete,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteSingleData(int index) async {
    final localization = AppLocalizations.of(context)!;
    await dataBox.deleteAt(index);
    setState(() {
      // Remove from uploaded indexes if it was there
      uploadedIndexes.remove(index);
    });
    Get.snackbar(
      localization.success,
      localization.success_delete,
      backgroundColor: Color.fromARGB(200, 76, 175, 79),
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      borderRadius: 10,
      margin: EdgeInsets.all(10),
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return GeneralScaffold(
      title: localization.choicepage_index_4,
      body: SafeArea(
        child: Column(
          children: [
            //Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: localization.search,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            //List Item
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: filteredTrackers.isEmpty
                    ? Center(
                        child: Text(
                          searchQuery.isEmpty
                              ? localization.noData
                              : localization.noResult,
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView.separated(
                          itemCount: filteredTrackers.length,
                          itemBuilder: (context, position) {
                            var trackerDataJson =
                                jsonEncode(filteredTrackers[position]);
                            var trackerObj = TrackerData.fromJson(
                                jsonDecode(trackerDataJson));

                            var date = DateFormat('yyyy-MM-dd')
                                .format(trackerObj.trackingEndTime);
                            var time = DateFormat('hh:mm a')
                                .format(trackerObj.trackingEndTime);

                            int originalIndex = dataBox.values
                                .toList()
                                .indexOf(filteredTrackers[position]);
                            bool isUploading =
                                uploadingIndexes.contains(originalIndex);
                            bool isUploaded = trackerObj.isUploaded;

                            Widget trailingButton;

                            if (isUploaded) {
                              trailingButton = Container(
                                height: 36,
                                width: 36,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Icon(Icons.check_circle,
                                    size: 20, color: Colors.green),
                              );
                            } else {
                              trailingButton = SizedBox(
                                height: 36,
                                width: 36,
                                child: OutlinedButton(
                                  onPressed: isUploading
                                      ? null
                                      : () async {
                                          // Show confirmation bottom sheet
                                          bool confirmUpload =
                                              await showModalBottomSheet<bool>(
                                                    context: context,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    isScrollControlled: true,
                                                    builder: (context) =>
                                                        Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .vertical(
                                                          top: Radius.circular(
                                                              20),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            localization.upload,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(height: 12),
                                                          // Message
                                                          Text.rich(
                                                            TextSpan(
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                              children: [
                                                                TextSpan(
                                                                    text:
                                                                        "${localization.confirm_upload} "),
                                                                TextSpan(
                                                                  text:
                                                                      trackerObj
                                                                          .name,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                TextSpan(
                                                                    text: "?"),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 24),
                                                          // Buttons row
                                                          Row(
                                                            children: [
                                                              // Cancel button
                                                              Expanded(
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          false),
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            16),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    localization
                                                                        .cancel,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  width: 12),
                                                              // Upload button
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          true),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            16),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .blue,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    localization
                                                                        .upload,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 8),
                                                        ],
                                                      ),
                                                    ),
                                                  ) ??
                                                  false;

                                          if (confirmUpload != true) return;

                                          setState(() {
                                            uploadingIndexes.add(position);
                                          });

                                          bool success =
                                              await uploadTrackerData(
                                                  trackerObj);

                                          if (success) {
                                            trackerObj.isUploaded = true;
                                            await dataBox.putAt(
                                                position, trackerObj.toJson());
                                            setState(() {
                                              uploadedIndexes.add(position);
                                            });
                                          }

                                          setState(() {
                                            uploadingIndexes.remove(position);
                                          });
                                        },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.zero,
                                    side: BorderSide(color: Colors.blue),
                                  ),
                                  child: isUploading
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.blue,
                                          ),
                                        )
                                      : Icon(
                                          Icons.cloud_upload,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  //Location Icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.location_on,
                                        color: Colors.blueAccent),
                                  ),
                                  const SizedBox(width: 16),

                                  // Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trackerObj.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${localization.date} : ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: date,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                              TextSpan(text: "\n"), // New line
                                              TextSpan(
                                                text: '${localization.time} : ',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text: time,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Upload button
                                      trailingButton,
                                      const SizedBox(width: 8),

                                      // View button
                                      SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: OutlinedButton(
                                          onPressed: () => _showTrackerDetails(
                                              context, trackerObj),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.all(8),
                                            side: BorderSide(
                                                color: Colors.yellow.shade700),
                                          ),
                                          child: Icon(Icons.visibility,
                                              size: 20,
                                              color: Colors.yellow.shade700),
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      // Delete button
                                      SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _showDeleteConfirmationForItem(
                                                  originalIndex, trackerObj),
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: EdgeInsets.all(8),
                                            side: BorderSide(
                                                color: Colors.red.shade700),
                                          ),
                                          child: Icon(Icons.delete,
                                              size: 20,
                                              color: Colors.red.shade700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                        ),
                      ),
              ),
            ),
            if (dataBox.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: FilledButton.icon(
                  onPressed: _showDeleteConfirmation,
                  icon: Icon(Icons.delete_forever),
                  label: Text(localization.deleteAll),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> uploadTrackerData(TrackerData data) async {
    final localization = AppLocalizations.of(context)!;

    try {
      var token = authBox.get(TOKEN_KEY);

      var header = {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      };

      Map<String, dynamic> body = {
        "name": data.name,
        "mod_trail_id": data.modTrailId.toString(),
        "kaedah_trail_id": data.kaedahTrailId.toString(),
        "interval": data.interval.toString(),
        "interval_type_id": data.intervalTypeId.toString(),
        "start_point": data.startPoint,
        "end_point": data.endPoint,
        "point_created": jsonEncode(data.locationPoints),
        "negeri_id": data.negeriId.toString()
      };

      var url = Uri.parse(ApiEndpoints.rekodTrail);

      var value = await http.post(url, headers: header, body: body);

      var resJson = jsonDecode(value.body);
      var status = resJson["status"].toString().toLowerCase();
      var message = resJson["message"].toString();

      Get.snackbar(
        status == "success" ? localization.success : localization.error,
        status == "success"
            ? '${data.name} ${localization.success_upload}'
            : message,
        backgroundColor: status == "success"
            ? const Color.fromARGB(200, 76, 175, 79)
            : Color.fromARGB(200, 244, 67, 54),
        colorText: Colors.white,
        icon: Icon(
            status == "success" ? Icons.check_circle : Icons.error_outline,
            color: Colors.white),
        borderRadius: 10,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
      );

      return status == "success";
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        e.toString(),
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: const Color.fromARGB(200, 244, 67, 54),
        colorText: Colors.white,
        borderRadius: 10,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 3),
      );
      return false;
    }
  }
}



// name - String
// mod_trail_id - numeric
// kaedah_trail_id - numeric
// interval - numeric
// interval_type_id - numeric
// start_point - String
// end_point - string
// point_created - string
// negeri_id - numeric