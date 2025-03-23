class ClassModel {
  final String id;
  final String name;
  final int strength;

  ClassModel({
    required this.id,
    required this.name,
    required this.strength,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      strength: json['strength'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'strength': strength,
    };
  }
}