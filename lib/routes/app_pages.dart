import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mini_service_booking_app/presentation/pages/edit_service_page.dart';
import 'package:mini_service_booking_app/presentation/pages/home_page.dart';
import 'package:mini_service_booking_app/presentation/pages/login_page.dart';
import 'package:mini_service_booking_app/presentation/pages/service_details_page.dart';
import '../core/bindings/service_binding.dart';
import '../presentation/pages/add_service_page.dart';
import 'app_routes.dart';
class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.addService,
      page: () => AddServicePage(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: '/service/:id',
      page: () => ServiceDetailsPage(serviceId: Get.parameters['id']!),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: '/edit-service/:id',
      page: () => EditServicePage(serviceId: Get.parameters['id']!),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: ServiceBinding(),
    ),
  ];
}
