import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/delivery_provider.dart';
import '../models/delivery.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SupervisorScreen extends StatelessWidget {
  const SupervisorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Supervisor'),
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
        builder: (context, deliveryProvider, child) {
          // El Consumer ya se vuelve a ejecutar cuando deliveryProvider llama a notifyListeners().
          return Column(
            children: [
              _buildSummary(deliveryProvider),
              Expanded(
                child: DefaultTabController(
                  length: 2, // pestañas: Todas, Por Repartidor
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
                            _buildAllDeliveriesList(deliveryProvider),
                            _buildByRiderList(context, deliveryProvider),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
        tooltip: 'Crear tarea',
        onPressed: () => _showDeliveryDialog(context),
      ),
    );
  }

  Widget _buildSummary(DeliveryProvider dp) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      final padding = isNarrow ? 12.0 : 24.0;
      return Container(
        padding: EdgeInsets.all(padding),
        color: Colors.green[50],
        child: Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 12,
          runSpacing: 12,
          children: [
            _animatedStatCard('Total', dp.allDeliveries.length, Colors.blue, Icons.list_alt, isNarrow),
            _animatedStatCard('Pendientes', dp.pendingCount, Colors.orange, Icons.pending, isNarrow),
            _animatedStatCard('Completadas', dp.completedCount, Colors.green, Icons.check_circle, isNarrow),
          ],
        ),
      );
    });
  }

  Widget _animatedStatCard(String label, int count, Color color, IconData icon, bool compact) {
    final width = compact ? 100.0 : 140.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 400),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildAllDeliveriesList(DeliveryProvider provider) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;
      return ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 24, vertical: 12),
        itemCount: provider.allDeliveries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final d = provider.allDeliveries[index];
          return _buildDeliveryCard(d);
        },
      );
    });
  }

  Widget _buildByRiderList(BuildContext context, DeliveryProvider dp) {
    final riderNames = dp.allDeliveries.map((d) => d.assignedTo).whereType<String>().toSet().toList();

    if (riderNames.isEmpty) {
      return const Center(child: Text('No hay repartidores asignados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riderNames.length,
      itemBuilder: (ctx, index) {
        final riderName = riderNames[index];
        final deliveries = dp.getDeliveriesForRider(riderName);
        final completed = deliveries.where((d) => d.isCompleted).length;
        final total = deliveries.length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(riderName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$completed/$total completadas'),
            children: [
              if (deliveries.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(alignment: Alignment.centerLeft, child: Text('Entregas', style: TextStyle(fontWeight: FontWeight.bold))),
                ),
                ...deliveries.map((d) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: _buildDeliveryCard(d))),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeliveryCard(Delivery delivery) {
    // Builder para obtener BuildContext local y usarlo en los callbacks
    return Builder(builder: (context) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: delivery.isCompleted ? Colors.green[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: delivery.isCompleted ? Colors.green.shade100 : Colors.orange.shade50,
            child: Icon(delivery.isCompleted ? Icons.check : Icons.local_shipping, color: delivery.isCompleted ? Colors.green : Colors.orange),
          ),
          title: Text('${delivery.id} • ${delivery.customerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 6),
            Text(delivery.address),
            if (delivery.isCompleted && delivery.completedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('Completada: ${DateFormat('dd/MM HH:mm').format(delivery.completedAt!)}', style: const TextStyle(fontSize: 12)),
              ),
          ]),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(label: Text(delivery.assignedTo ?? 'Sin asignar'), backgroundColor: Colors.green[100]),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showDeliveryDialog(context, editing: delivery),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDeleteDelivery(context, delivery.id),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showDeliveryDialog(BuildContext context, {Delivery? editing}) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    final titleCtrl = TextEditingController(text: editing?.customerName ?? '');
    final addrCtrl = TextEditingController(text: editing?.address ?? '');
    String? assigned = editing?.assignedTo;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editing == null ? 'Nueva entrega' : 'Editar entrega'),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(editing == null ? 'Crear nueva entrega' : 'Editar entrega', key: ValueKey(editing?.id))),
                const SizedBox(height: 12),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Cliente / Título')),
                const SizedBox(height: 8),
                TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'Dirección')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  value: assigned,
                  items: [null, ...deliveryProvider.allDeliveries.map((d) => d.assignedTo).whereType<String>().toSet()]
                      .map((r) => DropdownMenuItem(value: r, child: Text(r ?? 'Sin asignar')))
                      .toList(),
                  onChanged: (v) => assigned = v,
                  decoration: const InputDecoration(labelText: 'Asignar a'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final customer = titleCtrl.text.trim();
              final address = addrCtrl.text.trim();
              if (customer.isEmpty || address.isEmpty) return;
              if (editing == null) {
                // delegar generación de id al provider para mantener consistencia
                deliveryProvider.addDelivery(customerName: customer, address: address, assignedTo: assigned);
              } else {
                deliveryProvider.updateDelivery(editing.id, customerName: customer, address: address, assignedTo: assigned);
              }
              Navigator.pop(ctx);
            },
            child: Text(editing == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDelivery(BuildContext context, String id) {
    final deliveryProvider = Provider.of<DeliveryProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar entrega'),
        content: const Text('¿Eliminar esta entrega?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              deliveryProvider.deleteDelivery(id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar la sesión actual?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
