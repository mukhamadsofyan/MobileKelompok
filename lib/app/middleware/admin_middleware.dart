import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final user = Supabase.instance.client.auth.currentUser;

    // Ambil role dari metadata (default member)
    final role = user?.userMetadata?['role'] ?? 'member';

    // Jika bukan admin → redirect
    if (role != 'admin') {
      return const RouteSettings(name: '/forbidden');
    }

    return null; // lanjutkan
  }
}
