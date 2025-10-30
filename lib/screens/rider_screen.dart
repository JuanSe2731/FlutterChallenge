import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/delivery_provider.dart';
import '../models/delivery.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RiderScreen extends StatelessWidget {
  final String riderName;

  const RiderScreen({super.key, required this.riderName});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Entregas - ${riderName.isNotEmpty ? (riderName[0].toUpperCase() + riderName.substring(1)) : riderName}'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, dProvider, child) {
          final myDeliveries = dProvider.getDeliveriesForRider(riderName);
          final pending = myDeliveries.where((d) => !d.isCompleted).toList();
          final completed = myDeliveries.where((d) => d.isCompleted).toList();

          return Column(
            children: [
              _buildHeader(pending.length, completed.length),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (pending.isNotEmpty) ...[
                      const Text('Pendientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...pending.map((d) => _buildDeliveryCard(context, d)),
                    ],
                    if (completed.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Completadas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...completed.map((d) => _buildDeliveryCard(context, d)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int pending, int completed) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Pendientes', pending, Colors.orange),
          _buildStat('Completadas', completed, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Delivery delivery) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: delivery.isCompleted ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  delivery.isCompleted ? Icons.check_circle : Icons.schedule,
                  key: ValueKey(delivery.isCompleted),
                  color: delivery.isCompleted ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('${delivery.id} • ${delivery.customerName}', style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.location_on, size: 18), const SizedBox(width: 8), Expanded(child: Text(delivery.address))]),
          if (delivery.isCompleted && delivery.completedAt != null) ...[
            const SizedBox(height: 8),
            Text('Completada: ${DateFormat('dd/MM/yyyy HH:mm').format(delivery.completedAt!)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
          if (!delivery.isCompleted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _completeDelivery(context, delivery.id),
                icon: const Icon(Icons.check),
                label: const Text('Marcar como entregado'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _completeDelivery(BuildContext context, String deliveryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar entrega'),
        content: const Text('¿Confirmas que se completó esta entrega?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<DeliveryProvider>(context, listen: false)
                  .completeDelivery(deliveryId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Entrega completada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar la sesión actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
