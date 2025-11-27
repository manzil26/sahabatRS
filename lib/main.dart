import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://ppvjjumolctwzrednvul.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwdmpqdW1vbGN0d3pyZWRudnVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQxMjU3NDksImV4cCI6MjA3OTcwMTc0OX0.62vU78949hwLBnNzuPq_hrGMwPY5aH7jFRzRbmvIJJc",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TestDatabasePage());
  }
}

class TestDatabasePage extends StatefulWidget {
  @override
  State<TestDatabasePage> createState() => _TestDatabasePageState();
}

class _TestDatabasePageState extends State<TestDatabasePage> {
  String result = "Loading...";

  @override
  void initState() {
    super.initState();
    testDatabase();
  }

  Future<void> testDatabase() async {
    try {
      final data = await Supabase.instance.client
          .from('nama_tabel_kamu')
          .select();

      setState(() {
        result = data.toString();
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Supabase')),
      body: Padding(padding: const EdgeInsets.all(20), child: Text(result)),
    );
  }
}
