import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RegisterModel {
  String nome;
  String perfil;
  String email;
  String password;
  String telefone;
  String endereco;
  int CEP;
  bool active;
  RegisterModel({
    required this.nome,
    required this.perfil,
    required this.email,
    required this.password,
    required this.telefone,
    required this.endereco,
    required this.active,
    required this.CEP,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "records": [
        {
          "fields": {
            'Nome': nome,
            'Perfil': perfil,
            'Email': email,
            'Telefone': telefone,
            'Endereço': endereco,
            'Password': password,
            'Conta ativa': active,
            'CEP': CEP
          }
        }
      ]
    };
  }

  factory RegisterModel.fromMap(Map<String, dynamic> map) {
    return RegisterModel(
        nome: map['Nome'] as String,
        perfil: map['Perfil'] as String,
        email: map['Email'] as String,
        telefone: map['Telefone'] as String,
        endereco: map['Endereço'] as String,
        password: map['Password'] as String,
        active: map['Password'] as bool,
        CEP: map['CEP']);
  }

  String toJson() => json.encode(toMap());

  factory RegisterModel.fromJson(String source) =>
      RegisterModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
