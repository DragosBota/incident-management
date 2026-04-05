import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/servicies/auth_servicies.dart';
import '../models/incident.dart';
import '../servicies/incident_service.dart';
import 'create_incident_screen.dart';
import 'incident_detail_screen.dart';

class IncidentsHomeScreen extends StatefulWidget {
  const IncidentsHomeScreen({super.key});

  @override
  State<IncidentsHomeScreen> createState() => _IncidentsHomeScreenState();
}

class _IncidentsHomeScreenState extends State<IncidentsHomeScreen> {
  final IncidentService _incidentService = IncidentService();
  final AuthService _authService = AuthService();

  List<Incident> _incidents = [];
  bool _isLoading = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final incidents = await _incidentService.fetchIncidents();

      if (!mounted) return;

      setState(() {
        _incidents = incidents;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading incidents: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreateIncidentScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateIncidentScreen(),
      ),
    );

    if (result == true) {
      await _loadIncidents();
    }
  }

  Future<void> _openIncidentDetailScreen(String incidentId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentDetailScreen(
          incidentId: incidentId,
        ),
      ),
    );

    if (result == true) {
      await _loadIncidents();
      return;
    }

    await _loadIncidents();
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
      }
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: _isSigningOut ? null : _handleSignOut,
        icon: const Icon(Icons.logout),
        tooltip: 'Sign out',
      ),
      title: const Text('Incidents'),
      actions: [
        IconButton(
          onPressed: _openCreateIncidentScreen,
          icon: const Icon(Icons.add),
          tooltip: 'Create incident',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_incidents.isEmpty) {
      return const Center(
        child: Text(
          'No incidents found',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _incidents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final incident = _incidents[index];

        return Card(
          child: ListTile(
            onTap: () => _openIncidentDetailScreen(incident.id),
            title: Text(incident.incidentCode),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Customer: ${incident.customerName}'),
                Text('Status: ${incident.status}'),
                Text('Created: ${incident.createdAt.toLocal()}'),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}