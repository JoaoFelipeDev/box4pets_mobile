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
    final fields = (map['fields'] as Map?) ?? const {};
    String s(dynamic v) => (v ?? '').toString();
    return UserAuthModel(
      id: s(map['id']),
      nomeCompleto: s(fields['Nome']),
      perfil: s(fields['Perfil']),
      email: s(fields['Email']),
      telefone: s(fields['Telefone']),
      endereco: s(fields['Endereço']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserAuthModel.fromJson(String source) =>
      UserAuthModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
