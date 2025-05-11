import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingUtil {
  static void showLoading([String message = "Loading..."]) {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
