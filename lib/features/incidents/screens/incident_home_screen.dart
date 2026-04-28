import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/auth_service.dart';
import '../models/incident.dart';
import '../models/incident_list_filter.dart';
import '../services/incident_service.dart';
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
  bool _isSyncing = false;
  IncidentListFilter _selectedFilter = IncidentListFilter.opened;

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
      final incidents = await _incidentService.fetchIncidents(
        filter: _selectedFilter,
      );

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

  Future<void> _handleSync() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      await _incidentService.syncPendingChanges();
      await _loadIncidents();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pending changes synced'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error syncing changes: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  String _getSyncStatusLabel(String syncStatus) {
    switch (syncStatus) {
      case 'PENDING_CREATE':
        return 'Pending create';
      case 'PENDING_UPDATE':
        return 'Pending update';
      case 'PENDING_DELETE':
        return 'Pending delete';
      case 'SYNCED':
        return 'Synced';
      default:
        return syncStatus;
    }
  }

  Color _getSyncStatusColor(String syncStatus) {
    switch (syncStatus) {
      case 'SYNCED':
        return Colors.green;
      case 'PENDING_DELETE':
        return Colors.red;
      case 'PENDING_CREATE':
      case 'PENDING_UPDATE':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildSyncStatusChip(String syncStatus) {
    final color = _getSyncStatusColor(syncStatus);

    return Chip(
      label: Text(
        _getSyncStatusLabel(syncStatus),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
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
          onPressed: _isSyncing ? null : _handleSync,
          icon: _isSyncing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          tooltip: 'Sync pending changes',
        ),
        IconButton(
          onPressed: _openCreateIncidentScreen,
          icon: const Icon(Icons.add),
          tooltip: 'Create incident',
        ),
      ],
    );
  }

  String _getFilterLabel(IncidentListFilter filter) {
    switch (filter) {
      case IncidentListFilter.opened:
        return 'Opened';
      case IncidentListFilter.closed:
        return 'Closed';
      case IncidentListFilter.deleted:
        return 'Deleted';
    }
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: IncidentListFilter.values.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getFilterLabel(filter)),
              selected: _selectedFilter == filter,
              onSelected: (selected) async {
                if (!selected) return;

                setState(() {
                  _selectedFilter = filter;
                });

                await _loadIncidents();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case IncidentListFilter.opened:
        return 'No opened incidents found';
      case IncidentListFilter.closed:
        return 'No closed incidents found';
      case IncidentListFilter.deleted:
        return 'No deleted incidents found';
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_incidents.isEmpty) {
      return Center(
        child: Text(
          _getEmptyMessage(),
          style: const TextStyle(fontSize: 18),
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
                Text('Department: ${incident.departmentAt}'),
                Text('Created: ${incident.createdAt.toLocal()}'),
                const SizedBox(height: 6),
                _buildSyncStatusChip(incident.syncStatus),
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
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }
}
