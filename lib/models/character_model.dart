class ICharacter {
  final String name;
  final String description;
  final String profileUrl;

  ICharacter({
    required this.name,
    required this.description,
    required this.profileUrl,
  });

  factory ICharacter.fromJson(Map<String, dynamic> json) {
    return ICharacter(
      name: json['name'] as String,
      description: json['description'] as String,
      profileUrl: json['profile_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'profile_url': profileUrl,
    };
  }
}
