import 'dart:convert';

class ChangePasswordmodel {
  String id;
  String password;
  ChangePasswordmodel({
    required this.id,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      "records": [
        {
          "id": id,
          "fields": {
            'Password': password,
          }
        }
      ]
    };
  }

  factory ChangePasswordmodel.fromMap(Map<String, dynamic> map) {
    return ChangePasswordmodel(
      id: map['id'] ?? '',
      password: map['password'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ChangePasswordmodel.fromJson(String source) => ChangePasswordmodel.fromMap(json.decode(source));
}
