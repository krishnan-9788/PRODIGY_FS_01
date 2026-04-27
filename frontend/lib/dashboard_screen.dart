import 'package:flutter/material.dart';

import 'api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  String _message = 'Loading dashboard...';
  String _username = '';
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final result = await _apiService.getDashboardData();

    if (result['status'] == 200) {
      setState(() {
        _hasError = false;
        _isLoading = false;
        _username = result['data']?['username'] ?? '';
        _message = result['data']?['message'] ?? 'Secure dashboard loaded successfully!';
      });
    } else {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _message = result['data']?['error'] ?? 'Unable to load dashboard. Please login again.';
      });
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasError ? Icons.error_outline : Icons.check_circle_outline,
                      size: 80,
                      color: _hasError ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 24),
                    if (_username.isNotEmpty) ...[
                      Text(
                        'Welcome, $_username!',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _hasError ? Colors.red : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_hasError)
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Return to Login'),
                      )
                  ],
                ),
        ),
      ),
    );
  }
}
