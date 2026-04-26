class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  // and your PC's IP for real devices.
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 
  
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String users = '/users';
  static const String chat = '/chat';
}
