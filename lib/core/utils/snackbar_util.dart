import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtil {
  static void showError(String message) {
    Get.snackbar('Error', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }

  static void showSuccess(String message) {
    Get.snackbar('Success', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
