import 'dart:convert';
import 'package:egp/Constants.dart';
import 'package:egp/tracker/tracker_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:egp/general_layout.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  void _showTrackerDetails(BuildContext context, TrackerData trackerObj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trackerObj.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Start Point: ${trackerObj.startPoint}"),
              Text("End Point: ${trackerObj.endPoint}"),
              Text("Interval: ${trackerObj.interval}"),
              SizedBox(height: 20),
              Text("Location Points:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...trackerObj.locationPoints.map(
                  (point) => Text("- Lat: ${point.lat}, Lng: ${point.lon}")),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text('Are you sure you want to delete all data?'),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _deleteAllData();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text('Delete'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Function to handle data deletion
  Future<void> _deleteAllData() async {
    await dataBox.clear();
    setState(() {
      uploadedIndexes.clear();
    });
    Get.snackbar(
      "Berjaya",
      "Data sudah dipadam",
      backgroundColor: const Color.fromARGB(166, 76, 175, 79),
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
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: dataBox.isEmpty
                    ? Center(
                        child: Text(
                          "Tiada data",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(
                              () {}); // You can re-fetch or reload Hive box if needed
                        },
                        child: ListView.separated(
                          itemCount: dataBox.length,
                          itemBuilder: (context, position) {
                            var trackerDataJson =
                                jsonEncode(dataBox.getAt(position));
                            var trackerObj = TrackerData.fromJson(
                                jsonDecode(trackerDataJson));

                            bool isUploading =
                                uploadingIndexes.contains(position);
                            bool isUploaded = trackerObj.isUploaded;

                            Widget trailingButton;

                            if (isUploaded) {
                              trailingButton = Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Uploaded",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              );
                            } else {
                              trailingButton = OutlinedButton.icon(
                                onPressed: isUploading
                                    ? null
                                    : () async {
                                        setState(() {
                                          uploadingIndexes.add(position);
                                        });

                                        bool success =
                                            await uploadTrackerData(trackerObj);

                                        if (success) {
                                          // Update the tracker object
                                          trackerObj.isUploaded = true;

                                          // Save updated data back to Hive
                                          await dataBox.putAt(
                                              position, trackerObj.toJson());

                                          // Update UI
                                          setState(() {
                                            uploadedIndexes.add(position);
                                          });
                                        }

                                        setState(() {
                                          uploadingIndexes.remove(position);
                                        });
                                      },
                                icon: isUploading
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.blue,
                                        ),
                                      )
                                    : Icon(Icons.upload, size: 18),
                                label: Text(
                                    isUploading ? "Uploading..." : "Upload"),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  foregroundColor: Colors.blue,
                                  side: BorderSide(color: Colors.blue),
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
                                  Icon(Icons.location_on,
                                      color: Colors.blueAccent),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trackerObj.name,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        InkWell(
                                          onTap: () => _showTrackerDetails(
                                              context, trackerObj),
                                          child: Text(
                                            'Lihat ->',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  trailingButton,
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
                  label: Text("Clear Database"),
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

      var url = Uri.parse("https://myegp.forestry.gov.my/api/rekod-trail");

      var value = await http.post(url, headers: header, body: body);

      var resJson = jsonDecode(value.body);
      var status = resJson["status"];
      var message = resJson["message"];

      Get.snackbar(
        status.toString(),
        message.toString(),
        icon: Icon(Icons.check_circle, color: Colors.white),
        borderRadius: 10,
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
      );

      return status.toString().toLowerCase() == "success";
    } catch (e) {
      Get.snackbar(
        "Upload Failed",
        e.toString(),
        icon: Icon(Icons.error, color: Colors.white),
        backgroundColor: Colors.red,
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