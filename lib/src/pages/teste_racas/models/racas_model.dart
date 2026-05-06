import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class RacasModel {
  String id;
  String raca;
  String regiao_origem;
  String? origem_raca;
  String peso;
  String altura;
  String expectativa_de_vida;
  String pelagem;
  String principais_caracteristicas;
  String cuidados_gerais;
  String voce_sabia;
  String popularidade;
  String health;
  double? porcent;
  String? url;
  String? descricao_raca;
  RacasModel({
    required this.id,
    required this.raca,
    required this.regiao_origem,
    required this.origem_raca,
    required this.peso,
    required this.altura,
    required this.expectativa_de_vida,
    required this.pelagem,
    required this.principais_caracteristicas,
    required this.cuidados_gerais,
    required this.voce_sabia,
    required this.popularidade,
    required this.health,
    this.porcent,
    this.url,
    this.descricao_raca,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'raca': raca,
      'regiao_origem': regiao_origem,
      'peso': peso,
      'altura': altura,
      'expectativa_de_vida': expectativa_de_vida,
      'pelagem': pelagem,
      'principais_caracteristicas': principais_caracteristicas,
      'cuidados_gerais': cuidados_gerais,
      'voce_sabia': voce_sabia,
      'popularidade': popularidade,
      'health': health,
      'origem_raca': origem_raca,
    };
  }

  factory RacasModel.fromMap(Map<String, dynamic> map) {
    return RacasModel(
      id: map['id'] as String,
      raca: map['fields']['Raças'] ?? '',
      regiao_origem: map['fields']['Região de Origem'] ?? '',
      peso: map['fields']['Peso'] ?? '',
      altura: map['fields']['Altura'] ?? '',
      expectativa_de_vida: map['fields']['Expectativa de Vida'] ?? '',
      pelagem: map['fields']['Pelagem'] ?? '',
      principais_caracteristicas:
          map['fields']['Principais Características'] ?? '',
      cuidados_gerais: map['fields']['Cuidados Gerais'] ?? '',
      voce_sabia: map['fields']['Você Sabia?'] ?? '',
      popularidade: map['fields']['Popularidade'] ?? '',
      health: map['fields']['Health Genes for each Breed'] ?? '',
      origem_raca: map['fields']['Origem da Raça'] != null
          ? map['fields']['Origem da Raça'] as String
          : null,
      descricao_raca: map['fields']['Descrição da Raça'] != null
          ? map['fields']['Descrição da Raça'] as String
          : null,
      url: map['fields']['banner'] != null
          ? map['fields']['banner'][0]['url'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RacasModel.fromJson(String source) =>
      RacasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
