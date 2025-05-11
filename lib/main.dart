import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_service_booking_app/data/models/service_model.dart';
import 'package:mini_service_booking_app/l10n/translations.dart';
import 'package:mini_service_booking_app/routes/app_pages.dart';
import 'package:mini_service_booking_app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ServiceModelAdapter());
  await Hive.openBox<ServiceModel>('servicesBox');

  runApp(GetMaterialApp(
    title: 'Mini Service Booking App',
    translations: AppTranslations(),
    locale: const Locale('en', 'US'),
    fallbackLocale: const Locale('en', 'US'),
    initialRoute: AppRoutes.login,
    getPages: AppPages.routes,
    debugShowCheckedModeBanner: false,
  ));
}
