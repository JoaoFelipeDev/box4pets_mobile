import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserActivationModel {
  String id;
  String name;
  String perfil;
  String email;
  String telefone;
  String endereco;
  UserActivationModel({
    required this.id,
    required this.name,
    required this.perfil,
    required this.email,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'perfil': perfil,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
    };
  }

  factory UserActivationModel.fromMap(Map<String, dynamic> map) {
    return UserActivationModel(
      id: map['id'] as String,
      name: map['Nome completo'] as String,
      perfil: map['Perfil'] as String,
      email: map['Email'] as String,
      telefone: map['Telefone'] as String,
      endereco: map['Endereço'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserActivationModel.fromJson(String source) =>
      UserActivationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
