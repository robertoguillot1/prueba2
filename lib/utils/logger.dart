class AppLogger {
  static void info(String message, [Map<String, dynamic>? data]) {
    print('[INFO] $message${data != null ? ' - $data' : ''}');
  }

  static void warning(String message, [dynamic data]) {
    print('[WARNING] $message${data != null ? ' - $data' : ''}');
  }

  static void error(String message, dynamic error, StackTrace stackTrace) {
    print('[ERROR] $message');
    print('Error: $error');
    print('StackTrace: $stackTrace');
  }
}











