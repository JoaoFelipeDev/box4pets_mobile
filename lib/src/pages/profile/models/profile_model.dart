import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileModel {
  String id;
  String name;
  String perfil;
  String email;
  String telefone;
  String endereco;
  String? url;
  ProfileModel({
    required this.id,
    required this.name,
    required this.perfil,
    required this.email,
    required this.telefone,
    required this.endereco,
    this.url,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'perfil': perfil,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'url': url,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      name: map['fields']['Nome'] as String,
      perfil: map['fields']['Perfil'] as String,
      email: map['fields']['Email'] as String,
      telefone: map['fields']['Telefone'] as String,
      endereco: map['fields']['Endereço'] as String,
      url: map['fields']['Foto'] != null
          ? map['fields']['Foto'][0]['url'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) =>
      ProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
