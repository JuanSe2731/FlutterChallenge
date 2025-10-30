class Delivery {
  final String id;
  String customerName;
  String address;
  String? assignedTo;
  bool isCompleted;
  DateTime createdAt;
  DateTime? completedAt;

  Delivery({
    required this.id,
    required this.customerName,
    this.address = '',
    this.assignedTo,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'address': address,
      'assignedTo': assignedTo,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Delivery.fromJson(Map<String, dynamic> map) {
    return Delivery(
      id: map['id'] as String,
      customerName: map['customerName'] as String,
      address: map['address'] as String? ?? '',
      assignedTo: map['assignedTo'] as String?,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : null,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
    );
  }

  Delivery copyWith({
    String? id,
    String? customerName,
    String? address,
    String? assignedTo,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Delivery(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      assignedTo: assignedTo ?? this.assignedTo,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
