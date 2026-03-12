import 'package:flutter/material.dart';

void main() {
  runApp(const IncidentManagementApp());
}


class IncidentManagementApp extends StatelessWidget {
  const IncidentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Management',
      debugShowCheckedModeBanner: false,

      // Defines the global visual theme of the application.
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // The first screen that the user sees when the app launches.
      home: const HomePage(),
    );
  }
}

// Home page of the application.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top navigation bar of the screen.
      appBar: AppBar(
        title: const Text('Incident Management'),
      ),

      // Main content of the screen.
      body: const Center(
        child: Text(
          'Incident Management - Base Project',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
