import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserAuthModel {
  String id;
  String nomeCompleto;
  String perfil;
  String email;
  String telefone;
  String endereco;
  UserAuthModel({
    required this.id,
    required this.nomeCompleto,
    required this.perfil,
    required this.email,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'Nome completo': nomeCompleto,
      'Perfil': perfil,
      'Email': email,
      'Telefone': telefone,
      'Endereço': endereco,
    };
  }

  factory UserAuthModel.fromMap(Map<String, dynamic> map) {
    return UserAuthModel(
      id: map['id'] as String,
      nomeCompleto: map['fields']['Nome'] as String,
      perfil: map['fields']['Perfil'] as String,
      email: map['fields']['Email'] as String,
      telefone: map['fields']['Telefone'] as String,
      endereco: map['fields']['Endereço'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuthModel.fromJson(String source) =>
      UserAuthModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
