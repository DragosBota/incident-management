import 'package:flutter/material.dart';
import '../../auth/models/profile.dart';
import '../../auth/services/auth_service.dart';
import '../models/incident.dart';
import '../models/incident_log.dart';
import '../models/incident_status.dart';
import '../services/incident_service.dart';
import 'edit_incident_screen.dart';

class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;

  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
  });

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  static const String commercialDepartmentName = 'Commercial';
  static const String qualityDepartmentName = 'Quality';

  final IncidentService _incidentService = IncidentService();
  final AuthService _authService = AuthService();

  Incident? _incident;
  List<IncidentLog> _logs = [];
  List<Map<String, dynamic>> _departments = [];

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  bool _isDeletingIncident = false;
  bool _canManageIncident = false;

  String? _selectedStatus;
  String? _selectedDepartmentId;
  String? _currentDepartmentName;

  @override
  void initState() {
    super.initState();
    _loadIncidentDetail();
  }

  Future<void> _loadIncidentDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final incident =
          await _incidentService.fetchIncidentById(widget.incidentId);
      final logs = await _incidentService.fetchIncidentLogs(widget.incidentId);
      final departments = await _authService.fetchDepartments();
      final currentDepartmentName =
          await _fetchCurrentDepartmentName(departments);
      final canManageIncident =
          currentDepartmentName == commercialDepartmentName;

      if (!mounted) return;

      final selectedStatus = _isStatusAllowedForDepartment(
        incident.status,
        currentDepartmentName,
      )
          ? incident.status
          : null;

      setState(() {
        _incident = incident;
        _logs = logs;
        _departments = departments;
        _selectedStatus = selectedStatus;
        _selectedDepartmentId = incident.departmentAt;
        _canManageIncident = canManageIncident;
        _currentDepartmentName = currentDepartmentName;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading incident detail: $error'),
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

  Future<String?> _fetchCurrentDepartmentName(
    List<Map<String, dynamic>> departments,
  ) async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) return null;

    final Profile profile = await _authService.fetchProfile(currentUser.id);

    final department = departments.firstWhere(
      (d) => d['id'] == profile.departmentId,
      orElse: () => <String, dynamic>{},
    );

    return department['name'] as String?;
  }

  bool get _isCommercial => _currentDepartmentName == commercialDepartmentName;

  bool get _isQuality => _currentDepartmentName == qualityDepartmentName;

  bool _isStatusAllowedForDepartment(String status, String? departmentName) {
    if (status == IncidentStatus.registered) {
      return false;
    }

    if (status == IncidentStatus.inReview) {
      return departmentName == qualityDepartmentName;
    }

    if (status == IncidentStatus.closed) {
      return departmentName == commercialDepartmentName;
    }

    return true;
  }

  List<String> get _allowedStatuses {
    return IncidentStatus.values.where((status) {
      return _isStatusAllowedForDepartment(status, _currentDepartmentName);
    }).toList();
  }

  String? _validateStatusPermission(String status) {
    if (status == IncidentStatus.registered) {
      return 'REGISTERED is assigned automatically when creating an incident';
    }

    if (status == IncidentStatus.inReview && !_isQuality) {
      return 'Only Quality can set status to IN_REVIEW';
    }

    if (status == IncidentStatus.closed && !_isCommercial) {
      return 'Only Commercial can close incidents';
    }

    return null;
  }

  Future<void> _openEditScreen() async {
    if (_incident == null) return;

    if (!_canManageIncident) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only Commercial can edit incidents'),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditIncidentScreen(incident: _incident!),
      ),
    );

    if (result == true) {
      await _loadIncidentDetail();
    }
  }

  Future<void> _handleUpdateStatus() async {
    if (_incident == null) return;

    if (_selectedStatus == null || _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a valid status and department'),
        ),
      );
      return;
    }

    final permissionError = _validateStatusPermission(_selectedStatus!);

    if (permissionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(permissionError),
        ),
      );
      return;
    }

    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authenticated user found'),
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      await _incidentService.updateIncidentStatus(
        incidentId: _incident!.id,
        oldStatus: _incident!.status,
        newStatus: _selectedStatus!,
        newDepartmentId: _selectedDepartmentId!,
        userId: currentUser.id,
      );

      await _loadIncidentDetail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident status updated successfully'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating incident status: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _handleDeleteIncident() async {
    if (_incident == null) return;

    final reasonController = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete incident'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for deletion',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();

                if (reason.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a deletion reason'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, reason);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (reason == null) return;

    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No authenticated user found'),
        ),
      );
      return;
    }

    setState(() {
      _isDeletingIncident = true;
    });

    try {
      await _incidentService.softDeleteIncident(
        incidentId: _incident!.id,
        reason: reason,
        userId: currentUser.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident deleted successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting incident: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingIncident = false;
        });
      }
    }
  }

  String _getDepartmentName(String departmentId) {
    final match = _departments.where((d) => d['id'] == departmentId).toList();

    if (match.isEmpty) return departmentId;

    return match.first['name'] as String;
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
    return Chip(
      label: Text(
        _getSyncStatusLabel(syncStatus),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: _getSyncStatusColor(syncStatus),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildIncidentInfo(Incident incident) {
    final bool canEdit =
        _canManageIncident &&
        incident.status != IncidentStatus.closed &&
        incident.deletedAt == null;
    final bool isDeleted = incident.deletedAt != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident.incidentCode,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSyncStatusChip(incident.syncStatus),
            const SizedBox(height: 12),
            Text('Customer: ${incident.customerName}'),
            Text('SAP Order: ${incident.sapOrder}'),
            Text('Description: ${incident.description}'),
            Text('Status: ${incident.status}'),
            Text('Department At: ${_getDepartmentName(incident.departmentAt)}'),
            Text('Created By: ${incident.createdBy}'),
            Text('Created At: ${incident.createdAt.toLocal()}'),
            Text('Updated At: ${incident.updatedAt.toLocal()}'),
            Text('Resolution Type: ${incident.resolutionType ?? '-'}'),
            if (isDeleted)
              Text('Deleted At: ${incident.deletedAt!.toLocal()}'),
            if (isDeleted)
              Text('Deleted Reason: ${incident.deletedReason ?? '-'}'),
            if (isDeleted)
              Text('Deleted By: ${incident.deletedBy ?? '-'}'),
            const SizedBox(height: 16),
            Row(
              children: [
                if (canEdit)
                  ElevatedButton(
                    onPressed: _openEditScreen,
                    child: const Text('Edit incident'),
                  ),
                if (canEdit) const SizedBox(width: 12),
                if (_canManageIncident && !isDeleted)
                  ElevatedButton(
                    onPressed: _isDeletingIncident ? null : _handleDeleteIncident,
                    child: Text(
                      _isDeletingIncident ? 'Deleting...' : 'Delete incident',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusUpdateSection() {
    if (_incident?.deletedAt != null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Deleted incidents are read-only.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'New status',
              ),
              items: _allowedStatuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartmentId,
              decoration: const InputDecoration(
                labelText: 'Responsible department',
              ),
              items: _departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department['id'] as String,
                  child: Text(department['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartmentId = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isUpdatingStatus ? null : _handleUpdateStatus,
              child: Text(
                _isUpdatingStatus ? 'Updating...' : 'Update status',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogsSection() {
    if (_logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No history available'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._logs.map(
              (log) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.actionType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(log.description),
                    Text('Old Status: ${log.oldStatus ?? '-'}'),
                    Text('New Status: ${log.newStatus ?? '-'}'),
                    Text('Created By: ${log.createdBy}'),
                    Text('Created At: ${log.createdAt.toLocal()}'),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_incident == null) {
      return const Center(
        child: Text('Incident not found'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildIncidentInfo(_incident!),
        const SizedBox(height: 16),
        _buildStatusUpdateSection(),
        const SizedBox(height: 16),
        _buildLogsSection(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Detail'),
      ),
      body: _buildBody(),
    );
  }
}
