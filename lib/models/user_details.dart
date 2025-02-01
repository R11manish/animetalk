class UserDetails {
  final String name;
  final String email; 
  final String gender;
  final DateTime? dateOfBirth;

  UserDetails({
    required this.name,
    required this.email, 
    required this.gender,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email, 
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'] as String,
      email: json['email'] as String, 
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
    );
  }
}
