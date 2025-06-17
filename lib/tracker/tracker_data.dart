class TrackerData {
  late String name;
  late String startPoint;
  late String endPoint;
  late int modTrailId;
  late int kaedahTrailId;
  late int negeriId;
  late int interval;
  late int intervalTypeId;
  late bool isUploaded;
  late List<LocationPoints> locationPoints;
  late DateTime trackingEndTime;

  TrackerData({
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.modTrailId,
    required this.kaedahTrailId,
    required this.negeriId,
    required this.interval,
    required this.intervalTypeId,
    required this.locationPoints,
    required this.trackingEndTime,
    this.isUploaded = false,
  });

  TrackerData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    startPoint = json['start_point'];
    endPoint = json['end_point'];
    modTrailId = json['mod_trail_id'];
    kaedahTrailId = json['kaedah_trail_id'];
    negeriId = json['negeri_id'];
    interval = json['interval'];
    intervalTypeId = json['interval_type_id'];
    isUploaded = json["isUploaded"] ?? false;
    trackingEndTime = DateTime.parse(json['trackingEndTime']);
    if (json['location_points'] != null) {
      locationPoints = <LocationPoints>[];
      json['location_points'].forEach((v) {
        locationPoints.add(LocationPoints.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['start_point'] = startPoint;
    data['end_point'] = endPoint;
    data['mod_trail_id'] = modTrailId;
    data['kaedah_trail_id'] = kaedahTrailId;
    data['negeri_id'] = negeriId;
    data['interval'] = interval;
    data['interval_type_id'] = intervalTypeId;
    data['isUploaded'] = isUploaded;
    data['location_points'] = locationPoints.map((v) => v.toJson()).toList();
    data['trackingEndTime'] = trackingEndTime.toIso8601String();
    return data;
  }
}

class LocationPoints {
  double? lat;
  double? lon;

  LocationPoints({this.lat, this.lon});

  LocationPoints.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}
