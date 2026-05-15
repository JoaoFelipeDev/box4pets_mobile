import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class BlogModel {
  String id;
  String titulo;
  String subTitulo;
  List<Banner> banner;
  String conteudo;
  bool destaques;
  bool novidades;
  bool treinamentos;
  String autor;
  String dataCriacao;
  BlogModel({
    required this.id,
    required this.titulo,
    required this.subTitulo,
    required this.banner,
    required this.conteudo,
    required this.destaques,
    required this.novidades,
    required this.treinamentos,
    required this.autor,
    required this.dataCriacao,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'subTitulo': subTitulo,
      'banner': banner.map((x) => x.toMap()).toList(),
      'conteudo': conteudo,
      'destaques': destaques,
      'novidades': novidades,
      'treinamentos': treinamentos,
      'autor': autor,
      'dataCriacao': dataCriacao,
    };
  }

  factory BlogModel.fromMap(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] ?? '',
      titulo: map['fields']['Titulo'] ?? '',
      subTitulo: map['fields']['Subititulo'] ?? '',
      banner: List<Banner>.from(
        (map['fields']['Banner']).map<Banner>(
          (x) => Banner.fromMap(x as Map<String, dynamic>),
        ),
      ),
      conteudo: map['fields']['conteudo'] ?? '',
      destaques: map['fields']['Destaque'] ?? false,
      novidades: map['fields']['Raças'] ?? false,
      treinamentos: map['fields']['Traços e Doenças'] ?? false,
      autor: map['fields']['Autor'] ?? '',
      dataCriacao: (map['fields']['data de criação'] != null &&
              (map['fields']['data de criação'] as String).isNotEmpty)
          ? map['fields']['data de criação']
          : (map['createdTime'] ?? ''),
    );
  }

  String toJson() => json.encode(toMap());

  factory BlogModel.fromJson(String source) =>
      BlogModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Banner {
  String id;
  double width;
  double height;
  String url;
  String fileName;
  double size;
  Banner({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.fileName,
    required this.size,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'width': width,
      'height': height,
      'url': url,
      'fileName': fileName,
      'size': size,
    };
  }

  factory Banner.fromMap(Map<String, dynamic> map) {
    return Banner(
      id: map['id'] ?? '',
      width: double.parse(map['width'].toString()),
      height: double.parse(map['height'].toString()),
      url: map['url'] ?? '',
      fileName: map['filename'] ?? '',
      size: double.parse(map['size'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory Banner.fromJson(String source) =>
      Banner.fromMap(json.decode(source) as Map<String, dynamic>);
}
