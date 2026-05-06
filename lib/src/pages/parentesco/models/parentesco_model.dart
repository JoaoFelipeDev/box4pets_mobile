import 'dart:convert';

class ParentescoModel {
String numero_de_relatorio;
String swab_filho;
List<String> info_filho;
String swab_suposto_pai;
List<String> info_suposto_pai;
List<String> info_suposto_mae;
String email;
  ParentescoModel({
    required this.numero_de_relatorio,
    required this.swab_filho,
    required this.info_filho,
    required this.swab_suposto_pai,
    required this.info_suposto_pai,
    required this.email,
    required this.info_suposto_mae,
  });



  Map<String, dynamic> toMap() {
    return {
     'records': [
      {
        'fields': {
      'Número de Relatório': numero_de_relatorio,
      'Informe o SWAB do Filho': swab_filho,
      'Info Filho': info_filho,
      'Informe o SWAB do suposto Pai/Mãe': swab_suposto_pai,
      'Suposto Pai': info_suposto_pai,
      'E-mail para receber o resultado': email,
      'Suposta Mãe': info_suposto_mae,
        }
      }]
    };
  }

  factory ParentescoModel.fromMap(Map<String, dynamic> map) {
    return ParentescoModel(
      numero_de_relatorio: map['numero_de_relatorio'] ?? '',
      swab_filho: map['swab_filho'] ?? '',
      info_filho: List<String>.from(map['info_filho'] ?? const []),
      swab_suposto_pai: map['swab_suposto_pai'] ?? '',
      info_suposto_pai: List<String>.from(map['info_suposto_pai'] ?? const []),
      email: map['email'] ?? '',
      info_suposto_mae: List<String>.from(map['info_suposto_mae'] ?? const []),
    );
  }

  String toJson() => json.encode(toMap());

  factory ParentescoModel.fromJson(String source) => ParentescoModel.fromMap(json.decode(source));
}
