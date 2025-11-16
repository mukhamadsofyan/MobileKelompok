import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestSupabasePage extends StatefulWidget {
  const TestSupabasePage({super.key});

  @override
  State<TestSupabasePage> createState() => _TestSupabasePageState();
}

class _TestSupabasePageState extends State<TestSupabasePage> {
  String result = "Checking Supabase...";

  @override
  void initState() {
    super.initState();
    testQuery();
  }

  Future<void> testQuery() async {
    try {
      final supabase = Supabase.instance.client;

      final data = await supabase
          .from('activities')
          .select()
          .limit(1);

      setState(() {
        result = "✔ Connected to Supabase\n\nResponse:\n${data.toString()}";
      });
    } catch (e) {
      setState(() {
        result = "❌ Connection Failed\n\nError:\n$e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Supabase Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            result,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
