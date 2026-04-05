import 'package:flutter/material.dart';
import 'package:incident_management/features/auth/servicies/auth_servicies.dart';
import 'package:incident_management/features/incidents/screens/incident_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Key used to validate the form.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // Builds the AppBar of the screen.
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Login'),
    );
  }

  // Builds the main content of the screen.
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 32),
            _buildLoginButton(),
            const SizedBox(height: 12),
            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  // Builds the email input field.
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
        return null;
      },
    );
  }

  // Builds the password input field.
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  // Builds the login button.
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async{
        if (_formKey.currentState!.validate()) {
          _handleLogin();
        }
      },
      child: const Text('Login'),
    );
  }

  // Builds the registration button
  Widget _buildRegisterLink() {
  return TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        ),
      );
    },
    child: const Text('Create an account'),
  );
}

  // Handles the login action.
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception('Login failed: user not found');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const IncidentsHomeScreen(),
        ),
      );
    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: $error'),
        ),
      );
    }
  }
}