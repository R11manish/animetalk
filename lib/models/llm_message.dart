class LLMessage {
  final String role;
  final String content;

  LLMessage({
    required this.role,
    required this.content,
  });

  factory LLMessage.fromJson(Map<String, dynamic> json) {
    return LLMessage(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class LLMCharacter {
  final String name;
  final String gender;
  final String characterName;
  final String charDesc;
  final List<LLMessage> messages;

  LLMCharacter({
    required this.name,
    required this.gender,
    required this.characterName,
    required this.charDesc,
    required this.messages,
  });

  factory LLMCharacter.fromJson(Map<String, dynamic> json) {
    return LLMCharacter(
      name: json['name'],
      gender: json['gender'],
      characterName: json['character_name'],
      charDesc: json['char_desc'],
      messages: (json['messages'] as List)
          .map((messageJson) => LLMessage.fromJson(messageJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'character_name': characterName,
      'char_desc': charDesc,
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
