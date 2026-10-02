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

  /// Valor bruto do campo "Total Genes" no Airtable.
  int? total_genes;

  /// Painel canino: 222 registros no catálogo menos Nenhuma01/Nenhuma02.
  /// Livres = painel − 1 cópia − 2 cópias. O recorte por raça fica só
  /// em [doencasImportantesDaRaca].
  static const int painelGenesCanino = 220;

  static bool _isFelino(String? especie) =>
      (especie ?? '').toLowerCase() == 'felina';

  int get _somaTresCampos =>
      genes_sem_alteracao +
      gene_com_uma_variante_detectada +
      gene_com_duas_variante_detectada;

  /// Total exibido no app e no PDF. Cão: sempre 220. Gato: Airtable ou soma.
  int totalGenesAnalisados({String? especie}) {
    if (_isFelino(especie)) {
      return total_genes ?? _somaTresCampos;
    }
    return painelGenesCanino;
  }

  /// Card verde. Cão: 220 − uma variante − duas variantes.
  int genesLivres({String? especie}) {
    if (_isFelino(especie)) return genes_sem_alteracao;
    final livres = painelGenesCanino -
        gene_com_uma_variante_detectada -
        gene_com_duas_variante_detectada;
    return livres < 0 ? 0 : livres;
  }

  /// Compatível com chamadas antigas (painel canino).
  int get totalGenes => totalGenesAnalisados();

  int get doencasImportantesDaRaca =>
      principais_doencas_geneticas_da_raca.length;

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
    this.total_genes,
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
      'total_genes': total_genes,
    };
  }

  static List<String> _idList(dynamic value) {
    if (value is! List) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }

  factory AppResultadoResumoModel.fromMap(Map<String, dynamic> map) {
    final fields = map['fields'] as Map<String, dynamic>;
    return AppResultadoResumoModel(
      swab: fields['Swab'] as String,
      ativacao: fields['Ativacao'][0] as String,
      genes_sem_alteracao: fields['Genes sem alteração'] as int,
      gene_com_uma_variante_detectada:
          fields['Genes com uma variante detectada'] as int,
      gene_com_duas_variante_detectada:
          fields['Genes com duas variantes detectadas'] as int,
      tracos: fields['traços'] as int,
      uma_variante: _idList(
        fields['Uma Variante'] ?? fields['uma_variante_gato'],
      ),
      duas_variante: _idList(
        fields['Duas Variantes'] ?? fields['duas_variantes_gato'],
      ),
      principais_doencas_geneticas_da_raca: _idList(
        fields['Principais doenças genéticas da raça'] ??
            fields['Principais doenças genéticas da raça - gatos'],
      ),
      especie: _idList(fields['Espécie']),
      raca: _idList(fields['Raça']),
      todas_doencas_geneticas_avaliadas: _idList(
        fields['Todas doenças genéticas avaliadas'] ??
            fields['Todas doenças genéticas avaliadas - gatos'],
      ),
      total_genes: (fields['Total Genes'] as num?)?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppResultadoResumoModel.fromJson(String source) =>
      AppResultadoResumoModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
