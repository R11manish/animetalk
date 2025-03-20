class ApiEndpoints {
  static const String baseUrl =
      'https://alf9kf9ukl.execute-api.ap-south-1.amazonaws.com/';

  //otp
  static const String sendOtp = '/otp/send-otp';
  static const String verifyOtp = '/otp/verify-otp';

  //verify
  static const String health = '/health';

  //chat
  static const String chat = '/chat/characters';

  //characters
  //TODO:
  //- feature characters
  //- search characters
  //- request character
  static const String featured = 'characters/featured';

  static const String all = 'characters/all';

  //ads
  static const String adUnitId = '/ad-settings';
}
