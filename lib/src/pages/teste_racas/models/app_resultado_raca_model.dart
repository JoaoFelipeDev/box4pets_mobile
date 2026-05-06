import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AppResultadoRacaModel {
  String id;
  String racas;
  double porcent;
  AppResultadoRacaModel({
    required this.id,
    required this.racas,
    required this.porcent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'racas': racas,
      'porcent': porcent,
    };
  }

  factory AppResultadoRacaModel.fromMap(Map<String, dynamic> map) {
    return AppResultadoRacaModel(
      id: map['id'] as String,
      racas: map['fields']['Raça detectada'] as String,
      porcent: double.parse(map['fields']['portentagem'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppResultadoRacaModel.fromJson(String source) =>
      AppResultadoRacaModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
