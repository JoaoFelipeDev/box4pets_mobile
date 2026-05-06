import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ListTracosPdf {
  String marcador;
  String categoria;
  String tracos;
  String gene;
  String variante;
  String? resultado;
  ListTracosPdf({
    required this.marcador,
    required this.categoria,
    required this.tracos,
    required this.gene,
    required this.variante,
    this.resultado,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoria': categoria,
      'tracos': tracos,
      'gene': gene,
      'variante': variante,
      'resultado': resultado,
    };
  }

  factory ListTracosPdf.fromMap(Map<String, dynamic> map) {
    return ListTracosPdf(
      categoria: map['fields']['Categoria'] ?? '',
      marcador: map['fields']['Marcador'] ?? '',
      tracos: map['fields']['Traço'] ?? '',
      gene: map['fields']['Gene1'] ?? '',
      variante: map['fields']['Variante'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory ListTracosPdf.fromJson(String source) =>
      ListTracosPdf.fromMap(json.decode(source) as Map<String, dynamic>);
}
