import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ProfileEditingModel {
  String id;
  String nome;
  String perfil;
  String email;
  String telefone;
  String endereco;
  ProfileEditingModel({
    required this.id,
    required this.nome,
    required this.perfil,
    required this.email,
    required this.telefone,
    required this.endereco,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "records": [
        {
          "id": id,
          "fields": {
            'Nome': nome,
            'Perfil': perfil,
            'Email': email,
            'Telefone': telefone,
            'Endereço': endereco,
            'Conta ativa': true,
          }
        }
      ]
    };
  }

  factory ProfileEditingModel.fromMap(Map<String, dynamic> map) {
    return ProfileEditingModel(
      id: map['id'] as String,
      nome: map['nome'] as String,
      perfil: map['perfil'] as String,
      email: map['email'] as String,
      telefone: map['telefone'] as String,
      endereco: map['endereco'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileEditingModel.fromJson(String source) =>
      ProfileEditingModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
