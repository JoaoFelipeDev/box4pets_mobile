// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppAtivacaoModel {
  String id;
  String Case_ID;
  String name;
  String nascimento;
  String especie;
  String raca;
  String sexo;
  String? chip;
  String? url;
  String? registro;
  String nome_cliente;
  String swab;
  

  String? status_aplicativo;
  bool resultado;
  bool resultadoRaca;
  bool ourosTestes;

  AppAtivacaoModel({
    required this.id,
    required this.Case_ID,
    required this.name,
    required this.nascimento,
    required this.especie,
    required this.raca,
    required this.sexo,
    this.chip,
    this.url,
    this.registro,
    required this.nome_cliente,
    required this.swab,
    this.status_aplicativo,
    required this.resultado,
    required this.resultadoRaca,
    required this.ourosTestes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'Case_ID': Case_ID,
    };
  }

  factory AppAtivacaoModel.fromMap(Map<String, dynamic> map) {
    return AppAtivacaoModel(
      id: map['id'] as String,
      Case_ID: map['fields']['Case_ID'] as String,
      name: map['fields']['Nome do Pet'] as String,
      especie: map['fields']['Espécie'] as String,
      sexo: map['fields']['Sexo'] as String,
      raca: map['fields']['Raça'] as String,
      nome_cliente: map['fields']['Nome do Cliente'] as String,
      nascimento: map['fields']['Data de Nascimento'] as String,
      status_aplicativo: map['fields']['status aplicativo'] ?? '',
      url: map['fields']['url_image'] != null
          ? map['fields']['url_image'][0]['url']
          : null,
      chip: map['fields']['CHIP'] ?? '',
      registro: map['fields']['Registro'] ?? '',
      resultado: map['fields']['[APP] Resumo Resultado Doenças'] != null
          ? true
          : false,
      resultadoRaca:
          map['fields']['Resultado Teste Raça app'] != null ? true : false,
      swab: map['fields']['SWAB'] as String,
      ourosTestes: map['fields']['app_resultado_outrostestes'] != null ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppAtivacaoModel.fromJson(String source) =>
      AppAtivacaoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
