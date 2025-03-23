class StudentModel {
  final String id;
  final String name;
  final String rollNumber;
  bool isPresent;

  StudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    this.isPresent = false,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      rollNumber: json['rollNumber'] ?? json['id']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rollNumber': rollNumber,
    };
  }
}