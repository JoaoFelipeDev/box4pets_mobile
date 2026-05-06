import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

class AppResultadoRacaModel {
  String id;
  String id_interna;
  List<String> ativacao;
  List<String> raca_detectada;
  double porcentagem;
  AppResultadoRacaModel({
    required this.id,
    required this.id_interna,
    required this.ativacao,
    required this.raca_detectada,
    required this.porcentagem,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'id_interna': id_interna,
      'ativacao': ativacao,
      'raca_detectada': raca_detectada,
      'porcentagem': porcentagem,
    };
  }

  factory AppResultadoRacaModel.fromMap(Map<String, dynamic> map) {
    return AppResultadoRacaModel(
      id: map['id'] as String,
      id_interna: map['id_interna'] as String,
      ativacao: List<String>.from((map['ativacao'] as List<String>)),
      raca_detectada:
          List<String>.from((map['raca_detectada'] as List<String>)),
      porcentagem: double.parse(map['porcentagem'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppResultadoRacaModel.fromJson(String source) =>
      AppResultadoRacaModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
