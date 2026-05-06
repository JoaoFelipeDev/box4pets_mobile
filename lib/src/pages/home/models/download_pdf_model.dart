import 'dart:convert';

class DownloadPDFModel {
  String id;
  List url;
  List name;
  DownloadPDFModel({
    required this.id,
    required this.url,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
    };
  }

  factory DownloadPDFModel.fromMap(Map<String, dynamic> map) {
    return DownloadPDFModel(
      id: map['id'] ?? '',
      url: map['fields']['Attachments'].map((e) => e['url']  ).toList()  ?? '',
      name: map['fields']['Attachments'].map((e) => e['filename']).toList()  ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloadPDFModel.fromJson(String source) => DownloadPDFModel.fromMap(json.decode(source));
}
