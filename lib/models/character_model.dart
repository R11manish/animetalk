class ICharacter {
  final String name;
  final bool nameChecking;
  final String description;
  final String imageUrl;

  ICharacter({
    required this.name,
    required this.nameChecking,
    required this.description,
    required this.imageUrl,
  });

  factory ICharacter.fromJson(Map<String, dynamic> json) {
    return ICharacter(
      name: json['name'] as String,
      nameChecking: json['NameChecking'] as bool,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'NameChecking': nameChecking,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
