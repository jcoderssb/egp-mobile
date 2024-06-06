class TrackerData {
  late String name;
  late String startPoint;
  late String endPoint;
  late int modTrailId;
  late int kaedahTrailId;
  late int negeriId;
  late int interval;
  late int intervalTypeId;
  late List<LocationPoints> locationPoints;

  TrackerData({
        required this.name,
        required this.startPoint,
        required this.endPoint,
        required this.modTrailId,
        required this.kaedahTrailId,
        required this.negeriId,
        required this.interval,
        required this.intervalTypeId,
        required this.locationPoints
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
    if (json['location_points'] != null) {
      locationPoints = <LocationPoints>[];
      json['location_points'].forEach((v) {
        locationPoints!.add(new LocationPoints.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['start_point'] = this.startPoint;
    data['end_point'] = this.endPoint;
    data['mod_trail_id'] = this.modTrailId;
    data['kaedah_trail_id'] = this.kaedahTrailId;
    data['negeri_id'] = this.negeriId;
    data['interval'] = this.interval;
    data['interval_type_id'] = this.intervalTypeId;
    if (this.locationPoints != null) {
      data['location_points'] =
          this.locationPoints!.map((v) => v.toJson()).toList();
    }
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}
