import 'package:flutter/foundation.dart';
import '../models/delivery.dart';

class DeliveryProvider with ChangeNotifier {
  final List<Delivery> _deliveries = [
    Delivery(
      id: 'D001',
      customerName: 'Juan Pérez',
      address: 'Calle 123 #45-67',
      assignedTo: 'Carlos',
    ),
    Delivery(
      id: 'D002',
      customerName: 'María González',
      address: 'Carrera 45 #12-34',
      assignedTo: 'Carlos',
    ),
    Delivery(
      id: 'D003',
      customerName: 'Pedro Ramírez',
      address: 'Avenida 68 #23-45',
      assignedTo: 'Ana',
    ),
    Delivery(
      id: 'D004',
      customerName: 'Laura Martínez',
      address: 'Calle 78 #90-12',
      assignedTo: 'Ana',
    ),
  ];

  List<Delivery> get allDeliveries => _deliveries;

  List<Delivery> getDeliveriesForRider(String riderName) {
    return _deliveries
        .where((delivery) => delivery.assignedTo == riderName)
        .toList();
  }

  int get completedCount =>
      _deliveries.where((d) => d.isCompleted).length;

  int get pendingCount =>
      _deliveries.where((d) => !d.isCompleted).length;

  void completeDelivery(String deliveryId) {
    final delivery = _deliveries.firstWhere((d) => d.id == deliveryId);
    delivery.markAsCompleted();
    notifyListeners();
  }
}
