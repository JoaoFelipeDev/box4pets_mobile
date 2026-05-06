import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class AppListaDoencasModel {
  String marcador;
  String especie;
  String categoria;
  String doenca;
  String gene;
  String variante;
  String cromossomo;
  String heranca;
  String sobre_doenca;
  String manifesta;
  String recomendacoes;
  String referencias;
  String racas;

  AppListaDoencasModel({
    required this.marcador,
    required this.especie,
    required this.categoria,
    required this.doenca,
    required this.gene,
    required this.variante,
    required this.cromossomo,
    required this.heranca,
    required this.sobre_doenca,
    required this.manifesta,
    required this.recomendacoes,
    required this.referencias,
    required this.racas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'marcador': marcador,
      'especie': especie,
      'categoria': categoria,
      'doenca': doenca,
      'gene': gene,
      'variante': variante,
      'cromossomo': cromossomo,
      'heranca': heranca,
      'sobre_doenca': sobre_doenca,
      'manifesta': manifesta,
      'recomendacoes': recomendacoes,
      'racas': racas,
    };
  }

  factory AppListaDoencasModel.fromMap(Map<String, dynamic> map) {
    return AppListaDoencasModel(
      marcador: map['Marcador'] as String,
      especie: map['Espécie'] ?? '',
      categoria: map['Categoria'] ?? '',
      doenca: map['Doença'] ?? '',
      gene: map['Gene'] ?? '',
      variante: map['Variante'] ?? '',
      cromossomo: map['Cromossomo'] ?? '',
      heranca: map['Herança'] ?? '',
      sobre_doenca: map['Sobre a Doença'] ?? '',
      manifesta: map['Quando Manifesta'] ?? '',
      recomendacoes: map['Recomendações'] ?? '',
      racas: map['Raças'] ?? '',
      referencias: map['Referências'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppListaDoencasModel.fromJson(String source) =>
      AppListaDoencasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
