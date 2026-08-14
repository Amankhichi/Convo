class ApiEndpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: "http://192.168.0.114:7000",
  );

  static const String sendOtp = "/auth/send-otp";
  static const String requestOtp = "/api/auth/request-otp";
  static const String verifyOtp = "/auth/verify-otp";

  static const String updateUser = "/user/update";
  static const String addUser = "/user/add";
  static const String allUsers = "/user/all";
  static const String updateStatus = "/user/status";

  static const String allChats = "/chat/all";
  static const String addChat = "/chat/add";
  static const String chatsBetween = "/chat/between";
  static const String deleteChat = "/chat/delete";
  static const String updateChat = "/chat/update";
  static const String seenChat = "/chat/seen";
}
