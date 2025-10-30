import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/delivery.dart';

class DeliveryProvider extends ChangeNotifier {
  // contador para generar IDs cortos y legibles: D-1001, D-1002, ...
  int _counter = 1000;
  String _generateId() => 'D-${++_counter}';

  final List<Delivery> _deliveries = [];

  // key para SharedPreferences
  static const _kDeliveriesKey = 'deliveries_json';

  DeliveryProvider() {
    // cargar almacenado (si existe), si no inicializar con ejemplos
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = prefs.getString(_kDeliveriesKey);
      if (s != null) {
        final list = jsonDecode(s) as List<dynamic>;
        _deliveries.clear();
        _deliveries.addAll(list.map((m) => Delivery.fromJson(Map<String, dynamic>.from(m))));
        // ajustar contador para no colisionar con IDs existentes tipo D-XXXX
        int maxNum = _counter;
        for (final d in _deliveries) {
          final id = d.id;
          if (id.startsWith('D-')) {
            final part = int.tryParse(id.split('-').last);
            if (part != null && part > maxNum) maxNum = part;
          }
        }
        _counter = maxNum;
        notifyListeners();
        return;
      }
    } catch (_) {}
    // si no hay prefs o falla, crear ejemplos iniciales
    _deliveries.addAll([
      Delivery(
        id: _generateId(),
        customerName: 'Ana Pérez',
        address: 'Calle 1 #123',
        assignedTo: 'juan',
        isCompleted: false,
      ),
      Delivery(
        id: _generateId(),
        customerName: 'Carlos Gómez',
        address: 'Av. Siempre Viva 45',
        assignedTo: 'maria',
        isCompleted: true,
        completedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Delivery(
        id: _generateId(),
        customerName: 'Laura Ruiz',
        address: 'Diagonal 10 #5',
        assignedTo: 'juan',
        isCompleted: false,
      ),
    ]);
    notifyListeners();
    _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = jsonEncode(_deliveries.map((d) => d.toJson()).toList());
      await prefs.setString(_kDeliveriesKey, s);
    } catch (_) {}
  }

  List<Delivery> get allDeliveries => List.unmodifiable(_deliveries);

  List<Delivery> getDeliveriesForRider(String rider) =>
      // buscar de forma insensible a mayúsculas/minúsculas para evitar
      // que "Juan" y "juan" no coincidan.
      _deliveries.where((d) {
        final a = d.assignedTo;
        if (a == null) return false;
        return a.toLowerCase() == rider.toLowerCase();
      }).toList();

  int get pendingCount => _deliveries.where((d) => !d.isCompleted).length;
  int get completedCount => _deliveries.where((d) => d.isCompleted).length;

  // ahora id es opcional; si no se pasa se genera internamente para consistencia
  void addDelivery({
    String? id,
    required String customerName,
    String address = '',
    String? assignedTo,
  }) {
    final newId = id ?? _generateId();
    final delivery = Delivery(
      id: newId,
      customerName: customerName,
      address: address,
      assignedTo: assignedTo,
      isCompleted: false,
    );
    _deliveries.insert(0, delivery);
    notifyListeners();
    _saveToPrefs();
  }

  void updateDelivery(String id, {String? customerName, String? address, String? assignedTo}) {
    final idx = _deliveries.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    final d = _deliveries[idx];
    _deliveries[idx] = d.copyWith(
      customerName: customerName ?? d.customerName,
      address: address ?? d.address,
      assignedTo: assignedTo ?? d.assignedTo,
    );
    notifyListeners();
    _saveToPrefs();
  }

  void deleteDelivery(String id) {
    _deliveries.removeWhere((d) => d.id == id);
    notifyListeners();
    _saveToPrefs();
  }

  void completeDelivery(String id) {
    final idx = _deliveries.indexWhere((d) => d.id == id);
    if (idx == -1) return;
    final d = _deliveries[idx];
    if (!d.isCompleted) {
      _deliveries[idx] = d.copyWith(isCompleted: true, completedAt: DateTime.now());
      notifyListeners();
      _saveToPrefs();
    }
  }
}
