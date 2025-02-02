import 'package:intl/intl.dart';

class UserDetails {
  final String name;
  final String email;
  final String gender;
  final DateTime? dob;

  UserDetails({
    required this.name,
    required this.email,
    required this.gender,
    this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'dob': DateFormat('yyyy-MM-dd').format(dob!),
    };
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      dob: json['dob'] != null ? DateTime.parse(json['dob'] as String) : null,
    );
  }
}
