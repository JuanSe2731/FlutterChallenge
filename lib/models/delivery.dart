class Delivery {
  final String id;
  final String customerName;
  final String address;
  final String assignedTo;
  bool isCompleted;
  DateTime? completedAt;

  Delivery({
    required this.id,
    required this.customerName,
    required this.address,
    required this.assignedTo,
    this.isCompleted = false,
    this.completedAt,
  });

  void markAsCompleted() {
    isCompleted = true;
    completedAt = DateTime.now();
  }
}
