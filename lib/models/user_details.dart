import 'dart:convert';
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
      'dob': dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : null,
    };
  }

  factory UserDetails.fromString(String str) {
    final Map<String, dynamic> json = jsonDecode(str);
    return UserDetails.fromJson(json);
  }

  @override
  String toString() {
    return jsonEncode(toJson());
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

class AuthModel {
  final String? email;
  final String? otp;

  AuthModel({
    this.email,
    this.otp,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      email: json['email'] as String?,
      otp: json['otp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
