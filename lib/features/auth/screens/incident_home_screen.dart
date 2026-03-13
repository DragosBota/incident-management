import 'package:flutter/material.dart';

// Temporary home screen shown after successful login.
class IncidentsHomeScreen extends StatelessWidget {
  const IncidentsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents Temporary Home'),
      ),
      body: const Center(
        child: Text(
          'Login successful - Welcome to Incident Management',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}