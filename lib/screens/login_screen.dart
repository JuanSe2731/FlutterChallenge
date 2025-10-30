import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'rider_screen.dart';
import 'supervisor_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 100), () => _animCtrl.forward());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _login() {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    // validaciones básicas
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario y contraseña son requeridos')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLocked(username)) {
      final sec = auth.lockRemaining(username);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario bloqueado. Intenta en $sec s')),
      );
      return;
    }
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 1), () {
      final success = auth.login(
        username,
        password,
      );

      setState(() => _isLoading = false);

      if (success) {
        // marcar actividad y continuar
        auth.updateActivity();
        if (auth.role == 'rider') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RiderScreen(riderName: auth.currentUser!), // pasar username tal cual
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SupervisorScreen()),
          );
        }
      } else {
        if (auth.isLocked(username)) {
          final sec = auth.lockRemaining(username);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Demasiados intentos. Bloqueado por $sec s')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales inválidas')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth < 600 ? constraints.maxWidth * 0.92 : 480.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pedal_bike, size: 64, color: Colors.green),
                  const SizedBox(height: 8),
                  const Text('GreenGo Logistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person))),
                  const SizedBox(height: 12),
                  TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock))),
                  const SizedBox(height: 20),
                  _isLoading ? const CircularProgressIndicator(color: Colors.green) : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _login,
                      icon: const Icon(Icons.login),
                      label: const Text('Iniciar sesión'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}

