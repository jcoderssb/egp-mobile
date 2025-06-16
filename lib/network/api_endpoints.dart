class ApiEndpoints {
  // Base URL
  static const String baseUrl = "https://myegp.forestry.gov.my";
  // static const String baseUrl = "https://egp.jcoders.online";

  // API Endpoints
  static const String login = "$baseUrl/api/create-token";
  static const String dashboardPage = "$baseUrl/dashboards?isMobile=true&n=1";
  static const String rekodTrail = "$baseUrl/api/rekod-trail";
  static const String mapMobile = "$baseUrl/api/mapmobile?2D";
}
