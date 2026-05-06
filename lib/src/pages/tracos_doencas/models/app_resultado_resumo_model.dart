import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first, non_constant_identifier_names
class AppResultadoResumoModel {
  String swab;
  String ativacao;
  int genes_sem_alteracao;
  int gene_com_uma_variante_detectada;
  int gene_com_duas_variante_detectada;
  int tracos;
  List<String> uma_variante;
  List<String> duas_variante;
  List<String> principais_doencas_geneticas_da_raca;
  List<String> especie;
  List<String> raca;
  List<String> todas_doencas_geneticas_avaliadas;
  AppResultadoResumoModel({
    required this.swab,
    required this.ativacao,
    required this.genes_sem_alteracao,
    required this.gene_com_uma_variante_detectada,
    required this.gene_com_duas_variante_detectada,
    required this.tracos,
    required this.uma_variante,
    required this.duas_variante,
    required this.principais_doencas_geneticas_da_raca,
    required this.especie,
    required this.raca,
    required this.todas_doencas_geneticas_avaliadas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'swab': swab,
      'ativacao': ativacao,
      'genes_sem_alteracao': genes_sem_alteracao,
      'gene_com_uma_variante_detectada': gene_com_uma_variante_detectada,
      'gene_com_duas_variante_detectada': gene_com_duas_variante_detectada,
      'tracos': tracos,
      'uma_variante': uma_variante,
      'duas_variante': duas_variante,
      'principais_doencas_geneticas_da_raca':
          principais_doencas_geneticas_da_raca,
      'especie': especie,
      'raca': raca,
      'todas_doencas_geneticas_avaliadas': todas_doencas_geneticas_avaliadas,
    };
  }

  factory AppResultadoResumoModel.fromMap(Map<String, dynamic> map) {
    return AppResultadoResumoModel(
      swab: map['fields']['Swab'] as String,
      ativacao: map['fields']['Ativacao'][0] as String,
      genes_sem_alteracao: map['fields']['Genes sem alteração'] as int,
      gene_com_uma_variante_detectada:
          map['fields']['Genes com uma variante detectada'] as int,
      gene_com_duas_variante_detectada:
          map['fields']['Genes com duas variantes detectadas'] as int,
      tracos: map['fields']['traços'] as int,
      uma_variante: map['fields']['Uma Variante'] != null
          ? List<String>.from((map['fields']['Uma Variante'] as List<dynamic>))
          : List<String>.from(
              (map['fields']['uma_variante_gato'] as List<dynamic>)),
      duas_variante: map['fields']['Duas Variantes'] != null
          ? List<String>.from(
              (map['fields']['Duas Variantes'] as List<dynamic>))
          : List<String>.from(
              (map['fields']['duas_variantes_gato'] as List<dynamic>)),
      principais_doencas_geneticas_da_raca:
          map['fields']['Principais doenças genéticas da raça'] != null
              ? List<String>.from((map['fields']
                  ['Principais doenças genéticas da raça'] as List<dynamic>))
              : List<String>.from((map['fields']
                      ['Principais doenças genéticas da raça - gatos']
                  as List<dynamic>)),
      especie: List<String>.from((map['fields']['Espécie'] as List<dynamic>)),
      raca: List<String>.from((map['fields']['Raça'] as List<dynamic>)),
      todas_doencas_geneticas_avaliadas:
          map['fields']['Todas doenças genéticas avaliadas'] != null
              ? List<String>.from((map['fields']
                  ['Todas doenças genéticas avaliadas'] as List<dynamic>))
              : List<String>.from((map['fields']
                      ['Todas doenças genéticas avaliadas - gatos']
                  as List<dynamic>)),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppResultadoResumoModel.fromJson(String source) =>
      AppResultadoResumoModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
