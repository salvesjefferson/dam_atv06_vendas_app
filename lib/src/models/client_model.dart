import 'package:uuid/uuid.dart';

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? birthDate;

  ClientModel({
    String? id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
  }) : id = id ?? const Uuid().v4();

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      birthDate: map['birthDate'] != null
          ? DateTime.parse(map['birthDate'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClientModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  int? get age {
    if (birthDate == null) {
      return null;
    }

    final today = DateTime.now();
    int age = today.year - birthDate!.year;

    final hasNotHadBirthdayThisYear =
        today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day);

    if (hasNotHadBirthdayThisYear) {
      age--;
    }

    return age;
  }  

}
