import 'package:flutter/material.dart';
import 'rider_screen.dart';
import 'supervisor_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pedal_bike,
                size: 100,
                color: Colors.green[700],
              ),
              const SizedBox(height: 24),
              Text(
                'GreenGo Logistics',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Entregas sostenibles',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 48),
              _buildRoleButton(
                context,
                'Soy Repartidor',
                Icons.delivery_dining,
                () => _navigateAsRider(context),
              ),
              const SizedBox(height: 16),
              _buildRoleButton(
                context,
                'Soy Supervisor',
                Icons.admin_panel_settings,
                () => _navigateAsSupervisor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateAsRider(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona tu nombre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRiderOption(context, 'Carlos'),
            _buildRiderOption(context, 'Ana'),
          ],
        ),
      ),
    );
  }

  Widget _buildRiderOption(BuildContext context, String name) {
    return ListTile(
      leading: const Icon(Icons.person),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RiderScreen(riderName: name),
          ),
        );
      },
    );
  }

  void _navigateAsSupervisor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SupervisorScreen()),
    );
  }
}
