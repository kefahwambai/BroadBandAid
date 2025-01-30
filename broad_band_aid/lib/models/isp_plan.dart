class ISPPlan {
  final int id;
  final String name;
  final double price;
  final int dataLimit;
  final int speed;
  final String createdAt;
  final String updatedAt;

  ISPPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.dataLimit,
    required this.speed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ISPPlan.fromJson(Map<String, dynamic> json) {
    return ISPPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(), 
      dataLimit: json['dataLimit'] as int,
      speed: json['speed'] as int,
      createdAt: json['createdAt'] ?? '', 
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
