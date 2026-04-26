class ApiConstants {
  // Since you ran 'adb reverse tcp:3000 tcp:3000', 
  // your phone now sees the backend at 127.0.0.1
  static const String baseUrl = 'http://127.0.0.1:3000/api'; 
  
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String users = '/users';
  static const String chat = '/chat';
}
