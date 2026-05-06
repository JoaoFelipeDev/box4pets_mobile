// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ActivationModel {
  String name;
  String case_ID;
  String email;
  String phone;
  String swab;
  String namePet;
  String raca;
  String dataNascimento;
  String idade;
  String sexo;
  String peso;
  String perfil;
  String especie;
  String testes;
  String registro;
  String chip;
  String email_app_usuario;
  ActivationModel({
    required this.name,
    required this.case_ID,
    required this.email,
    required this.phone,
    required this.swab,
    required this.namePet,
    required this.raca,
    required this.dataNascimento,
    required this.idade,
    required this.sexo,
    required this.peso,
    required this.perfil,
    required this.especie,
    required this.testes,
    required this.registro,
    required this.chip,
    required this.email_app_usuario,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'records': [
        {
          'fields': {
            'Nome do Cliente': name,
            'Case_ID': case_ID,
            'Email': email,
            'Telefone': phone,
            'SWAB': swab, // 'Swab': 'Swab 1
            'Nome do Pet': namePet,
            'Raça': raca,
            'Data de Nascimento': dataNascimento,
            'Idade': idade,
            'Sexo': sexo,
            'Peso': double.parse(peso),
            'Perfil': perfil,
            'Espécie': especie,
            'email_app_usuario': [email_app_usuario],
            'Teste Adquirido': testes,
            'Registro': registro,
            'CHIP': chip,
          }
        }
      ]
    };
  }

  factory ActivationModel.fromMap(Map<String, dynamic> map) {
    return ActivationModel(
      name: map['name'] as String,
      case_ID: map['Case_ID'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      namePet: map['namePet'] as String,
      raca: map['raca'] as String,
      dataNascimento: map['dataNascimento'] as String,
      idade: map['idade'] as String,
      peso: map['peso'] as String,
      especie: map['especie'] as String,
      sexo: map['especie'] as String,
      perfil: map['especie'] as String,
      email_app_usuario: map['Email_app_usuario'] as String,
      testes: map['Email_app_usuario'] as String,
      registro: map['Email_app_usuario'] as String,
      chip: map['Email_app_usuario'] as String,
      swab: map['swab'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActivationModel.fromJson(String source) =>
      ActivationModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
