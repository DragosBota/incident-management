import 'package:flutter/material.dart';
import '../../auth/servicies/auth_servicies.dart';
import '../../auth/models/profile.dart';
import '../servicies/incident_service.dart';

class CreateIncidentScreen extends StatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  State<CreateIncidentScreen> createState() => _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends State<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _sapOrderController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final IncidentService _incidentService = IncidentService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isCheckingPermissions = true;
  bool _canCreateIncident = false;

  String? _currentDepartmentName;

  @override
  void initState() {
    super.initState();
    _checkCreatePermission();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _sapOrderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isCommercialDepartment(String? departmentName) {
    if (departmentName == null) return false;

    final normalized = departmentName.trim().toLowerCase();

    return normalized == 'commercial' ||
        normalized == 'comercial' ||
        normalized == 'sales';
  }

  Future<void> _checkCreatePermission() async {
    try {
      final departmentName = await _authService.fetchCurrentUserDepartmentName();

      if (!mounted) return;

      setState(() {
        _currentDepartmentName = departmentName;
        _canCreateIncident = _isCommercialDepartment(departmentName);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _currentDepartmentName = null;
        _canCreateIncident = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingPermissions = false;
        });
      }
    }
  }

  Future<void> _handleCreateIncident() async {
    if (!_canCreateIncident) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only Commercial can create incidents. Current department: ${_currentDepartmentName ?? 'unknown'}',
          ),
        ),
      );
      return;
    }

    final customerName = _customerNameController.text.trim();
    final sapOrder = _sapOrderController.text.trim();
    final description = _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      final Profile profile = await _authService.fetchProfile(currentUser.id);

      await _incidentService.createIncident(
        customerName: customerName,
        sapOrder: sapOrder,
        description: description,
        createdBy: profile.id,
        departmentAt: profile.departmentId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident created successfully'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      debugPrint('Error creating incident: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create incident: $error'),
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

  Widget _buildCustomerNameField() {
    return TextFormField(
      controller: _customerNameController,
      decoration: const InputDecoration(
        labelText: 'Customer name',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the customer name';
        }
        return null;
      },
    );
  }

  Widget _buildSapOrderField() {
    return TextFormField(
      controller: _sapOrderController,
      decoration: const InputDecoration(
        labelText: 'SAP order',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter the SAP order';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
      ),
      maxLines: 4,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                await _handleCreateIncident();
              }
            },
      child: Text(_isLoading ? 'Saving...' : 'Create incident'),
    );
  }

  Widget _buildUnauthorizedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You do not have permission to create incidents.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Detected department: ${_currentDepartmentName ?? 'unknown'}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text('Detected department: ${_currentDepartmentName ?? 'unknown'}'),
            const SizedBox(height: 16),
            _buildCustomerNameField(),
            const SizedBox(height: 16),
            _buildSapOrderField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isCheckingPermissions) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_canCreateIncident) {
      return _buildUnauthorizedView();
    }

    return _buildFormView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Incident'),
      ),
      body: _buildBody(),
    );
  }
}