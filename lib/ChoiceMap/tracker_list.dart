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

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return GeneralScaffold(
        title: localization.choicepage_index_4,
        body: Column(
          children: [
            Container(
              height: Get.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: ListView.separated(
                itemCount: dataBox.length,
                itemBuilder: (context, position) {
                  var trackerDataJson = jsonEncode(dataBox.getAt(position));

                  var trackerObj =
                      TrackerData.fromJson(jsonDecode(trackerDataJson));

                  return ListTile(
                    title: Text(trackerObj.name,
                        style: const TextStyle(color: whiteColor)),
                    subtitle: Text(
                      "${trackerObj.startPoint} - ${trackerObj.endPoint}",
                      style: const TextStyle(color: whiteColor),
                    ),
                    trailing: ElevatedButton.icon(
                        onPressed: () {
                          uploadTrackerData(trackerObj);
                        },
                        icon: const Icon(Icons.upload),
                        label: const Text("Upload")),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  dataBox.clear();
                  setState(() {});
                },
                child: const Text("Clear Database")),
          ],
        ));
  }

  //
// name - String
// mod_trail_id - numeric
// kaedah_trail_id - numeric
// interval - numeric
// interval_type_id - numeric
// start_point - String
// end_point - string
// point_created - string
// negeri_id - numeric

  uploadTrackerData(TrackerData data) async {
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

    await http.post(url, headers: header, body: body).then((value) {
      var response = value.body;
      var resJson = jsonDecode(response);
      var status = resJson["status"];
      var message = resJson["message"];

      Get.snackbar(status, message);
    });
  }
}
