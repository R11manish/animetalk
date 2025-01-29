class UserDetails {
  final String name;
  final String gender;
  final DateTime? dateOfBirth;

  UserDetails({
    required this.name,
    required this.gender,
    this.dateOfBirth,
  });
}
