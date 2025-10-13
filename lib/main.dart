import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/org_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const OrgTrackApp());
}

class OrgTrackApp extends StatelessWidget {
  const OrgTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrgProvider()..loadAll(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OrgTrack',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
