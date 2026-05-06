import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class RacasModel {
  // String id;
  String racas;
  RacasModel({
    // required this.id,
    required this.racas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      // 'id': id,
      'Raças': racas,
    };
  }

  factory RacasModel.fromMap(Map<String, dynamic> map) {
    return RacasModel(
      // id: map['id'] as String ?? '',
      racas: map['Name'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory RacasModel.fromJson(String source) =>
      RacasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
