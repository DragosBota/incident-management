import 'package:flutter/material.dart';
import '../servicies/auth_servicies.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Service responsible for authentication and profile persistence.
  final AuthService _authService = AuthService();

  // Controllers for text inputs.
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Selected department id from dropdown.
  String? _selectedDepartmentId;

  // Department list loaded from Supabase.
  List<Map<String, dynamic>> _departments = [];

  // Controls loading state during registration.
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Builds the AppBar.
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Register'),
    );
  }

  // Builds the body of the screen.
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildFirstNameField(),
            const SizedBox(height: 16),
            _buildLastNameField(),
            const SizedBox(height: 16),
            _buildDepartmentDropdown(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 32),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  // Loads departments from the database to populate the dropdown.
  Future<void> _loadDepartments() async {
    try {
      final departments = await _authService.fetchDepartments();

      setState(() {
        _departments = departments;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading departments: $error'),
        ),
      );
    }
  }

  // First name field.
  Widget _buildFirstNameField() {
  return TextFormField(
    controller: _firstNameController,
    decoration: const InputDecoration(
      labelText: 'First name',
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your first name';
      }

      final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
      if (!nameRegex.hasMatch(value)) {
        return 'Only letters are allowed';
      }
      return null;
    },
  );
}

  // Last name field.
  Widget _buildLastNameField() {
  return TextFormField(
    controller: _lastNameController,
    decoration: const InputDecoration(
      labelText: 'Last name',
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your last name';
      }

      final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
      if (!nameRegex.hasMatch(value)) {
        return 'Only letters are allowed';
      }
      return null;
    },
  );
}

  // Department dropdown loaded from database.
  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedDepartmentId,
      decoration: const InputDecoration(
        labelText: 'Department',
      ),
      hint: const Text("Select your department"),
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
      validator: (value) {
        if (value == null) {
          return 'Please select a department';
        }
        return null;
      },
    );
  }

  // Email field.
 Widget _buildEmailField() {
  return TextFormField(
    controller: _emailController,
    decoration: const InputDecoration(
      labelText: 'Email',
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your email';
      }

      final email = value.toLowerCase().trim();

      // Basic email format validation
      if (!email.contains('@')) {
        return 'Invalid email format';
      }

      // Corporate email domain validation
      if (!email.endsWith('@healthcarespain.com')) {
        return 'Only corporate emails are allowed';
      }

      return null;
    },
  );
}

  // Password field.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        return null;
      },
    );
  }

  // Register button.
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (_formKey.currentState!.validate()) {
                await _handleRegister();
              }
            },
      child: Text(_isLoading ? 'Registering...' : 'Register'),
    );
  }

  
  Future<void> _handleRegister() async {
  final firstName = _firstNameController.text.trim();
  final lastName = _lastNameController.text.trim();
  final email = _emailController.text.trim().toLowerCase();
  final password = _passwordController.text.trim();
  final departmentId = _selectedDepartmentId;

  if (departmentId == null) return;

  setState(() {
    _isLoading = true;
  });

  try {
debugPrint('STEP 1 - Starting sign up'); //DEBUG!!!!!!!!!

    final response = await _authService.signUp(
      email: email,
      password: password,
    );

debugPrint('STEP 2 - Sign up completed for $email');//DEBUG!!!!!!!!!

    final user = response.user;

    if (user == null) {
      throw Exception('User creation failed');
    }

debugPrint('STEP 3 - User ID obtained: ${user.id}');//DEBUG!!!!!!!!!
debugPrint('STEP 4 - Creating profile');//DEBUG!!!!!!!!!

    await _authService.createProfile(
      userId: user.id,
      firstName: firstName,
      lastName: lastName,
      departmentId: departmentId,
    );

debugPrint('STEP 5 - Profile created');//DEBUG!!!!!!!!!
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
debugPrint('Registration error: $error');//DEBUG!!!!!!!!!
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $error'),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }
}