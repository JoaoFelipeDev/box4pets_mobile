import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ListDoencasPdfModel {
  String marcador;
  String categoria;
  String doenca;
  String gene;
  String variante;
  String? resultado;

  ListDoencasPdfModel(
      {required this.marcador,
      required this.categoria,
      required this.doenca,
      required this.gene,
      required this.variante,
      this.resultado});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoria': categoria,
      'doenca': doenca,
      'gene': gene,
      'variante': variante,
    };
  }

  factory ListDoencasPdfModel.fromMap(Map<String, dynamic> map) {
    return ListDoencasPdfModel(
      marcador: map['fields']['Marcador'] ?? '',
      categoria: map['fields']['Categoria'] ?? '',
      doenca: map['fields']['Doença'] ?? '',
      gene: map['fields']['Gene'] ?? '',
      variante: map['fields']['Variante'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ListDoencasPdfModel.fromJson(String source) =>
      ListDoencasPdfModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
