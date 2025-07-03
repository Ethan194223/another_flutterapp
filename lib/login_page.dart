import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'main.dart'; // Import your main.dart file

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();

  bool _canCheckBiometric = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final availableBiometrics = await _auth.getAvailableBiometrics();

      if (!mounted) return;

      setState(() {
        _canCheckBiometric = canCheck;
        _availableBiometrics = availableBiometrics;
      });
    } on PlatformException {
      setState(() {
        _canCheckBiometric = false;
        _availableBiometrics = [];
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
      });

      authenticated = await _auth.authenticate(
        localizedReason: 'Authenticate to log in',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });

      if (authenticated) {
        _navigateToMainScreen();
      } else {
        _showError('Biometric authentication failed.');
      }
    } on PlatformException catch (e) {
      setState(() {
        _isAuthenticating = false;
      });
      _showError('Biometric authentication error: ${e.message}');
    }
  }

  void _loginWithCredentials() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError('Please enter both username and password.');
      return;
    }

    _navigateToMainScreen();
  }

  void _navigateToMainScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loginWithCredentials,
              child: const Text('Login with Username'),
            ),
            const SizedBox(height: 16),
            if (_canCheckBiometric && _availableBiometrics.isNotEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint),
                label: const Text('Login with Biometrics'),
                onPressed: _authenticateWithBiometrics,
              )
            else
              const Text(
                'Biometric authentication is not available.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

