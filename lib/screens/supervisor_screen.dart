import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/delivery_provider.dart';
import '../models/delivery.dart';

class SupervisorScreen extends StatelessWidget {
  const SupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Supervisor'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<DeliveryProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              _buildSummary(provider),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: Colors.green[700],
                        tabs: const [
                          Tab(text: 'Todas'),
                          Tab(text: 'Por Repartidor'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAllDeliveriesList(provider),
                            _buildByRiderList(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary(DeliveryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.green[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            'Total',
            provider.allDeliveries.length,
            Colors.blue,
            Icons.list_alt,
          ),
          _buildStatCard(
            'Pendientes',
            provider.pendingCount,
            Colors.orange,
            Icons.pending,
          ),
          _buildStatCard(
            'Completadas',
            provider.completedCount,
            Colors.green,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAllDeliveriesList(DeliveryProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.allDeliveries.length,
      itemBuilder: (context, index) {
        return _buildDeliveryCard(provider.allDeliveries[index]);
      },
    );
  }

  Widget _buildByRiderList(DeliveryProvider provider) {
    final riderNames = provider.allDeliveries
        .map((d) => d.assignedTo)
        .toSet()
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riderNames.length,
      itemBuilder: (context, index) {
        final riderName = riderNames[index];
        final deliveries = provider.getDeliveriesForRider(riderName);
        final completed = deliveries.where((d) => d.isCompleted).length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              riderName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '$completed/${deliveries.length} completadas',
            ),
            children: deliveries.map((d) => _buildDeliveryCard(d)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          delivery.isCompleted ? Icons.check_circle : Icons.schedule,
          color: delivery.isCompleted ? Colors.green : Colors.orange,
        ),
        title: Text('${delivery.id} - ${delivery.customerName}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(delivery.address),
            if (delivery.isCompleted && delivery.completedAt != null)
              Text(
                'Completada: ${DateFormat('dd/MM HH:mm').format(delivery.completedAt!)}',
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: Chip(
          label: Text(delivery.assignedTo),
          backgroundColor: Colors.green[100],
        ),
      ),
    );
  }
}
