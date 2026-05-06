import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class TracosModel {
  String id;
  String marcador;
  String categoria;
  String gene1;
  String traco;
  String cromossomo;
  String? sobre_traco;
  String? variante;
  String? racas;
  String? referencias;
  String especie;
  TracosModel({
    required this.id,
    required this.marcador,
    required this.categoria,
    required this.gene1,
    required this.traco,
    required this.cromossomo,
    this.sobre_traco,
    this.variante,
    this.racas,
    this.referencias,
    required this.especie,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'marcador': marcador,
      'categoria': categoria,
      'gene1': gene1,
      'traco': traco,
      'cromossomo': cromossomo,
      'sobre_traco': sobre_traco,
      'variante': variante,
      'racas': racas,
      'referencias': referencias,
      'especie': especie,
    };
  }

  factory TracosModel.fromMap(Map<String, dynamic> map) {
    return TracosModel(
      id: map['id'] as String,
      marcador: map['fields']['Marcador'] as String,
      categoria: map['fields']['Categoria'] as String,
      gene1: map['fields']['Gene1'] as String,
      traco: map['fields']['Traço'] as String,
      cromossomo: map['fields']['Cromossomo'] ?? '',
      sobre_traco: map['fields']['Sobre o Traço'] != null
          ? map['fields']['Sobre o Traço'] as String
          : null,
      variante: map['fields']['Variante'] != null
          ? map['fields']['Variante'] as String
          : null,
      racas: map['fields']['Raças'] != null
          ? map['fields']['Raças'] as String
          : null,
      referencias: map['fields']['Referências'] != null
          ? map['fields']['Referências'] as String
          : null,
      especie: map['fields']['Espécie'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TracosModel.fromJson(String source) =>
      TracosModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
