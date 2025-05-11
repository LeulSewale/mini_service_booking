class ErrorHandler {
  static String getMessage(dynamic error) {
    if (error.toString().contains("SocketException")) {
      return 'No internet connection';
    }
    // Add more custom logic if needed
    return 'Unexpected error: $error';
  }
}
