import 'dart:convert';

class AtivacaoParentescoModel {
String id;
String swab;
String nome;
  AtivacaoParentescoModel({
    required this.id,
    required this.swab,
    required this.nome,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'swab': swab,
      'nome': nome,
    };
  }

  factory AtivacaoParentescoModel.fromMap(Map<String, dynamic> map) {
    return AtivacaoParentescoModel(
      id: map['id'] ?? '',
      swab: map['fields']['SWAB'] ?? '',
      nome: map['fields']['Nome do Pet'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AtivacaoParentescoModel.fromJson(String source) => AtivacaoParentescoModel.fromMap(json.decode(source));
}
