// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mobile2025/Screens/events_screen.dart';
import 'package:mobile2025/Services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database; // Crée la DB
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     home: const EventsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}