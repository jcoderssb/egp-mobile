import 'package:egp/global.dart';

class ApiEndpoints {
  // Base URL
  static const String baseUrl = "https://myegp.forestry.gov.my";
  // static const String baseUrl = "https://egp.jcoders.online";

  // API Endpoints
  static const String login = "$baseUrl/api/create-token";
  static String get dashboardPage => "$baseUrl/dashboards?isMobile=true&$nID";
  static const String rekodTrail = "$baseUrl/api/rekod-trail";
  static String get mapMobile => "$baseUrl/api/mapmobile?2D&$nID";
}
