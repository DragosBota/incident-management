import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';


class IncidentManagementApp extends StatelessWidget {
  const IncidentManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Incident Management',
      debugShowCheckedModeBanner: false,

      // Global visual configuration of the app.
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // First screen displayed when the application starts.
      home: const LoginScreen(),
    );
  }
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Management'),
      ),
      body: const Center(
        child: Text(
          'Incident Management - Base Project',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}