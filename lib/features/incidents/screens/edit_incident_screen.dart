import 'package:flutter/material.dart';
import '../../auth/servicies/auth_servicies.dart';
import '../models/incident.dart';
import '../servicies/incident_service.dart';

class EditIncidentScreen extends StatefulWidget {
  final Incident incident;

  const EditIncidentScreen({
    super.key,
    required this.incident,
  });

  @override
  State<EditIncidentScreen> createState() => _EditIncidentScreenState();
}

class _EditIncidentScreenState extends State<EditIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final IncidentService _incidentService = IncidentService();
  final AuthService _authService = AuthService();

  late TextEditingController _customerNameController;
  late TextEditingController _sapOrderController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _customerNameController =
        TextEditingController(text: widget.incident.customerName);

    _sapOrderController =
        TextEditingController(text: widget.incident.sapOrder);

    _descriptionController =
        TextEditingController(text: widget.incident.description);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _sapOrderController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authenticated user')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _incidentService.updateIncident(
        incidentId: widget.incident.id,
        customerName: _customerNameController.text.trim(),
        sapOrder: _sapOrderController.text.trim(),
        description: _descriptionController.text.trim(),
        userId: currentUser.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incident updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating incident: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSave,
      child: Text(_isLoading ? 'Saving...' : 'Save changes'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Incident'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_customerNameController, 'Customer name'),
              const SizedBox(height: 16),
              _buildTextField(_sapOrderController, 'SAP order'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description'),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}