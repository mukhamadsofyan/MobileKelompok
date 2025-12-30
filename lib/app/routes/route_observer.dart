import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppRouteObserver extends GetObserver {
  final box = GetStorage();

  @override
  void didPush(Route route, Route? previousRoute) {
    _saveRoute(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _saveRoute(newRoute);
  }

  void _saveRoute(Route? route) {
    final name = route?.settings.name;
    if (name != null && !name.contains('login')) {
      box.write('last_route', name);
    }
  }
}
