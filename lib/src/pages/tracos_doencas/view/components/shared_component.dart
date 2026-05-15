import 'dart:convert';
import 'dart:async';

import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/models/list_tracos_pdf.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_viwer_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart' as material;

import '../../../ativacao/models/user_activation_model.dart';
import '../../../home/models/app_ativacao_model.dart';
import '../../models/list_doencas_pdf_model.dart';

final http = EndpointDio();
Future getDoencas(String id) async {
  final Response<dynamic> responseId =
      await http.dio.get('/app_lista_doenca/$id');
  var result = responseId.data['fields']['Marcador'];
  final Response<dynamic> response = await http.dio.get(
      '/app_lista_doenca?filterByFormula=Marcador="$result"&sort%5B0%5D%5Bfield%5D=Categoria&sort%5B0%5D%5Bdirection%5D=asc');
  return response.data['records'][0];
}

Future getDoencasGato(String id) async {
  final Response<dynamic> responseId =
      await http.dio.get('/app_lista_doenca_gato/$id');
  print('responseId: $responseId');
  var result = responseId.data['fields']['Marcador'];
  final Response<dynamic> response = await http.dio.get(
      '/app_lista_doenca_gato?filterByFormula=Marcador="$result"&sort%5B0%5D%5Bfield%5D=Categoria&sort%5B0%5D%5Bdirection%5D=asc');
  return response.data['records'][0];
}

Future getTracos() async {
  final Response<dynamic> response = await http.dio.get(
    '/app_lista_tracos',
    queryParameters: {
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    },
  );
  return response.data['records'];
}

Future getTracosGatos() async {
  final Response<dynamic> response = await http.dio.get(
    '/app_lista_tracos_gato',
    queryParameters: {
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    },
  );
  return response.data['records'];
}

Future<List<dynamic>> getTodasDoencas() async {
  List<dynamic> allRecords = [];
  String? offset;

  // Loop para buscar todas as páginas
  do {
    final queryParameters = {
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
      if (offset != null) 'offset': offset,
    };

    // Realiza a requisição com ou sem o offset
    final Response<dynamic> response = await http.dio.get(
      '/app_lista_doenca',
      queryParameters: queryParameters,
    );

    // Adiciona os registros à lista final
    allRecords.addAll(response.data['records']);

    // Atualiza o offset, se houver mais itens
    offset = response.data['offset'];
    print('total : ${allRecords.length}');
  } while (offset != null); // Continua enquanto houver um offset

  return allRecords;
}

// Future getTodasDoencas() async {
//   final Response<dynamic> response = await http.dio.get(
//       '/app_lista_doenca?sort%5B0%5D%5Bfield%5D=Categoria&sort%5B0%5D%5Bdirection%5D=asc');
//   return response.data['records'];
// }

Future getTodasDoencasGato() async {
  final Response<dynamic> response = await http.dio.get(
      '/app_lista_doenca_gato?sort%5B0%5D%5Bfield%5D=Categoria&sort%5B0%5D%5Bdirection%5D=asc');
  return response.data['records'];
}

final box = GetStorage();

// Função auxiliar para limitar concorrência
Future<List<T>> concurrentPool<T>(List<Future<T> Function()> tasks,
    {int maxConcurrent = 3}) async {
  final results = List<T?>.filled(tasks.length, null);
  int nextTask = 0;
  int completed = 0;
  final active = <int, Future<T>>{};

  void startTask(int i) {
    active[i] = tasks[i]().then((result) {
      results[i] = result;
      active.remove(i);
      completed++;
      return result;
    });
  }

  while (completed < tasks.length) {
    while (active.length < maxConcurrent && nextTask < tasks.length) {
      startTask(nextTask);
      nextTask++;
    }
    if (active.isNotEmpty) {
      await Future.any(active.values);
    }
  }
  return results.cast<T>();
}

reportView(
  context, {
  required void Function(String change, bool close, int progress) change,
  required List<String> umaVariate,
  required List<String> duasVariantes,
  required List<String> principais,
  required List<String> todas,
  required String name,
  required AppAtivacaoModel ativacao,
  void Function(String path)? onComplete,
}) async {
  final stopwatch = Stopwatch()..start();
  String json = box.read('user');
  UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
  List<ListDoencasPdfModel> uma_variante = [];
  List<ListDoencasPdfModel> duas_variante = [];
  List<ListDoencasPdfModel> principais_caracteristicas = [];
  List<ListDoencasPdfModel> todas_doencas = [];
  List<ListTracosPdf> tracos = [];

  change('Buscando resultados de uma variante', false, 1);
  // Busca paralela para uma variante com limite de concorrência
  uma_variante = await concurrentPool(
    umaVariate
        .map((element) => () async {
              Map<String, dynamic> map = {};
              if (ativacao.especie == "Felina") {
                map = await getDoencasGato(element);
              } else {
                map = await getDoencas(element);
              }
              final Response<dynamic> response = await http.dio.get(
                  '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');
              String result = "";
              if ((response.data['records'] as List).isNotEmpty) {
                var raw = response.data['records'][0]['fields']
                    [map['fields']['Marcador']];
                if (raw == null) {
                  result = "";
                } else if (raw is String) {
                  result = raw;
                } else {
                  result = raw.toString();
                }
              }
              return ListDoencasPdfModel(
                  marcador: (map['fields']['Marcador'] ?? '').toString(),
                  categoria: (map['fields']['Categoria'] ?? '').toString(),
                  doenca: (map['fields']['Doença'] ?? '').toString(),
                  gene: (map['fields']['Gene'] ?? '').toString(),
                  variante: (map['fields']['Variante'] ?? '').toString(),
                  resultado: result);
            })
        .toList(),
    maxConcurrent: 3,
  );

  change('Buscando resultados de duas variantes', false, 2);
  duas_variante = await concurrentPool(
    duasVariantes
        .map((element) => () async {
              Map<String, dynamic> map = {};
              if (ativacao.especie == "Felina") {
                map = await getDoencasGato(element);
              } else {
                map = await getDoencas(element);
              }
              final Response<dynamic> response = await http.dio.get(
                  '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');
              String result = "";
              if ((response.data['records'] as List).isNotEmpty) {
                var raw = response.data['records'][0]['fields']
                    [map['fields']['Marcador']];
                if (raw == null) {
                  result = "";
                } else if (raw is String) {
                  result = raw;
                } else {
                  result = raw.toString();
                }
              }
              return ListDoencasPdfModel(
                  marcador: (map['fields']['Marcador'] ?? '').toString(),
                  categoria: (map['fields']['Categoria'] ?? '').toString(),
                  doenca: (map['fields']['Doença'] ?? '').toString(),
                  gene: (map['fields']['Gene'] ?? '').toString(),
                  variante: (map['fields']['Variante'] ?? '').toString(),
                  resultado: result);
            })
        .toList(),
    maxConcurrent: 3,
  );
  duas_variante.sort((a, b) => a.categoria.compareTo(b.categoria));

  change(
      'Buscando resultados de Principais doenças genéticas da raça', false, 3);
  principais_caracteristicas = await concurrentPool(
    principais
        .map((element) => () async {
              Map<String, dynamic> map = {};
              if (ativacao.especie == "Felina") {
                map = await getDoencasGato(element);
              } else {
                map = await getDoencas(element);
              }
              final Response<dynamic> response = await http.dio.get(
                  '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');
              String result = "";
              if ((response.data['records'] as List).isNotEmpty) {
                var raw = response.data['records'][0]['fields']
                    [map['fields']['Marcador']];
                if (raw == null) {
                  result = "";
                } else if (raw is String) {
                  result = raw;
                } else {
                  result = raw.toString();
                }
              }
              return ListDoencasPdfModel(
                  marcador: (map['fields']['Marcador'] ?? '').toString(),
                  categoria: (map['fields']['Categoria'] ?? '').toString(),
                  doenca: (map['fields']['Doença'] ?? '').toString(),
                  gene: (map['fields']['Gene'] ?? '').toString(),
                  variante: (map['fields']['Variante'] ?? '').toString(),
                  resultado: result);
            })
        .toList(),
    maxConcurrent: 3,
  );
  principais_caracteristicas.sort((a, b) => a.categoria.compareTo(b.categoria));

  List<dynamic> resultTracos = [];
  if (ativacao.especie == "Felina") {
    resultTracos = await getTracosGatos();
  } else {
    resultTracos = await getTracos();
  }
  change('Buscando resultados de Traços', false, 4);
  tracos = await concurrentPool(
    resultTracos
        .map((element) => () async {
              final Response<dynamic> response = await http.dio.get(
                  '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');
              String result = "";
              if ((response.data['records'] as List).isNotEmpty) {
                var raw = response.data['records'][0]['fields']
                    [element['fields']['Marcador']];
                if (raw == null) {
                  result = "";
                } else if (raw is String) {
                  result = raw;
                } else {
                  result = raw.toString();
                }
              }
              return ListTracosPdf(
                  marcador: (element['fields']['Marcador'] ?? '').toString(),
                  categoria: (element['fields']['Categoria'] ?? '').toString(),
                  tracos: (element['fields']['Traço'] ?? '').toString(),
                  gene: (element['fields']['Gene1'] ?? '').toString(),
                  variante: (element['fields']['Variante'] ?? '').toString(),
                  resultado: result);
            })
        .toList(),
    maxConcurrent: 3,
  );

  int index = 5;
  final traco = tracos
      .map((e) => [e.categoria, e.tracos, e.gene, e.variante, e.resultado])
      .toList();
  List<dynamic> result = ativacao.especie == "Felina"
      ? await getTodasDoencasGato()
      : await getTodasDoencas();
  final umaVarianteData = uma_variante
      .map((e) => [e.categoria, e.doenca, e.gene, e.variante, e.resultado])
      .toList();
  change('Buscando resultados de Todas as doenças genéticas avaliadas', false,
      index);

  // Busca paralela para todas as doenças com limite de concorrência
  todas_doencas = await concurrentPool(
    result
        .map((element) => () async {
              final Response<dynamic> response = await http.dio.get(
                  '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');
              String resultValue = "";
              if (ativacao.especie == "Felina") {
                if ((response.data['records'] as List).isNotEmpty) {
                  var raw = response.data['records'][0]['fields']
                      [element['fields']['Marcador']];
                  if (raw == null) {
                    resultValue = "";
                  } else if (raw is String) {
                    resultValue = raw;
                  } else {
                    resultValue = raw.toString();
                  }
                }
              } else {
                index < 99 ? index += 1 : index = 99;
                change(
                    'Buscando resultados de Todas as doenças genéticas avaliadas',
                    false,
                    index);
                if ((response.data['records'] as List).isNotEmpty &&
                    element['fields']['Marcador'] != null &&
                    element['fields']['Marcador'] as String != '-') {
                  var raw = response.data['records'][0]['fields']
                      [element['fields']['Marcador']];
                  if (raw == null) {
                    resultValue = "";
                  } else if (raw is String) {
                    resultValue = raw;
                  } else {
                    resultValue = raw.toString();
                  }
                }
              }
              if ((response.data['records'] as List).isNotEmpty) {
                var raw = response.data['records'][0]['fields']
                    [element['fields']['Marcador']];
                if (raw == null) {
                  resultValue = "";
                } else if (raw is String) {
                  resultValue = raw;
                } else {
                  resultValue = raw.toString();
                }
              }
              return ListDoencasPdfModel(
                  marcador: (element['fields']['Marcador'] ?? '').toString(),
                  categoria: (element['fields']['Categoria'] ?? '').toString(),
                  doenca: (element['fields']['Doença'] ?? '').toString(),
                  gene: (element['fields']['Gene'] ?? '').toString(),
                  variante: (element['fields']['Variante'] ?? '').toString(),
                  resultado: resultValue);
            })
        .toList(),
    maxConcurrent: 3,
  );

  final duasVarianteData = duas_variante
      .map((e) => [e.categoria, e.doenca, e.gene, e.variante, e.resultado])
      .toList();
  final principaisData = principais_caracteristicas
      .map((e) => [e.categoria, e.doenca, e.gene, e.variante, e.resultado])
      .toList();
  final todasData = todas_doencas
      .map((e) => [e.categoria, e.doenca, e.gene, e.variante, e.resultado])
      .toList();

  final ByteData image =
      await rootBundle.load('assets/images/logoB4p_centralizado.png');

  Uint8List imageData = (image).buffer.asUint8List();
  List<List<dynamic>> allData = [
    ...duasVarianteData,
    ...principaisData,
    ...todasData
  ];
  int itemsPerPage = 20;
  final pdf = Document();
  // for de umaVarianteData
  for (int i = 0; i < umaVarianteData.length; i += itemsPerPage) {
    pdf.addPage(
      MultiPage(
          crossAxisAlignment: CrossAxisAlignment.start,
          header: (Context context) {
            return Container(
                margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
                alignment: Alignment.centerRight,
                child: Row(children: [
                  pw.Image(pw.MemoryImage(imageData), height: 50),
                  SizedBox(width: 20),
                  SizedBox(
                    width: 400,
                    child: Text(
                        'SAÚDE: Traços e Doenças - Nome do Pet: $name - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} - Registro: ${ativacao.registro} - Microchip: ${ativacao.chip} Nome do Tutor: ${ativacao.nome_cliente} - Endereço: ${user.endereco} ',
                        style: TextStyle(fontSize: 10)),
                  )
                ]));
          },
          footer: (Context context) {
            return Container(
                alignment: Alignment.centerRight,
                margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                child: Column(children: [
                  Container(width: double.infinity, height: 3),
                  Row(
                    children: [
                      Text(
                          'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446'),
                    ],
                  ),
                ]));
          },
          build: (Context context) => <Widget>[
                Padding(padding: const EdgeInsets.all(10)),
                Text('Uma variante detectada', style: TextStyle(fontSize: 18)),
                Padding(padding: const EdgeInsets.all(10)),
                TableHelper.fromTextArray(
                    cellAlignment: pw.Alignment.center,
                    cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                          border:
                              pw.Border.all(width: 0.5, color: PdfColors.grey),
                          borderRadius:
                              pw.BorderRadius.all(pw.Radius.circular(5)),
                        ),
                    border: pw.TableBorder(verticalInside: BorderSide.none),
                    context: context,
                    headers: [
                      'Categoria',
                      'Doença',
                      'Gene',
                      'Variante',
                      'Resultado'
                    ],
                    defaultColumnWidth: FixedColumnWidth(200),
                    data: umaVarianteData.sublist(
                        i,
                        i + itemsPerPage > umaVarianteData.length
                            ? umaVarianteData.length
                            : i + itemsPerPage)),
                Padding(padding: const EdgeInsets.all(10)),
              ]),
    );
    for (int i = 0; i < duasVarianteData.length; i += itemsPerPage) {
      pdf.addPage(
        MultiPage(
            crossAxisAlignment: CrossAxisAlignment.start,
            header: (Context context) {
              return Container(
                  margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
                  alignment: Alignment.centerRight,
                  child: Row(children: [
                    pw.Image(pw.MemoryImage(imageData), height: 50),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 400,
                      child: Text(
                          'SAÚDE: Traços e Doenças - Nome do Pet: $name - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} - Registro: ${ativacao.registro} - Microchip: ${ativacao.chip} Nome do Tutor: ${ativacao.nome_cliente} - Endereço: ${user.endereco} ',
                          style: TextStyle(fontSize: 10)),
                    )
                  ]));
            },
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                  child: Column(children: [
                    Container(width: double.infinity, height: 3),
                    Row(
                      children: [
                        Text(
                            'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446'),
                      ],
                    ),
                  ]));
            },
            build: (Context context) => <Widget>[
                  Padding(padding: const EdgeInsets.all(10)),
                  Text('Duas variante detectada',
                      style: TextStyle(fontSize: 18)),
                  Padding(padding: const EdgeInsets.all(10)),
                  TableHelper.fromTextArray(
                      cellAlignment: pw.Alignment.center,
                      cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5, color: PdfColors.grey),
                            borderRadius:
                                pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                      border: pw.TableBorder(verticalInside: BorderSide.none),
                      context: context,
                      headers: [
                        'Categoria',
                        'Doença',
                        'Gene',
                        'Variante',
                        'Resultado'
                      ],
                      defaultColumnWidth: FixedColumnWidth(200),
                      data: duasVarianteData.sublist(
                          i,
                          i + itemsPerPage > duasVarianteData.length
                              ? duasVarianteData.length
                              : i + itemsPerPage)),
                  Padding(padding: const EdgeInsets.all(10)),
                ]),
      );
    }
    for (int i = 0; i < principaisData.length; i += itemsPerPage) {
      pdf.addPage(
        MultiPage(
            crossAxisAlignment: CrossAxisAlignment.start,
            header: (Context context) {
              return Container(
                  margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
                  alignment: Alignment.centerRight,
                  child: Row(children: [
                    pw.Image(pw.MemoryImage(imageData), height: 50),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 400,
                      child: Text(
                          'SAÚDE: Traços e Doenças - Nome do Pet: $name - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} - Registro: ${ativacao.registro} - Microchip: ${ativacao.chip} Nome do Tutor: ${ativacao.nome_cliente} - Endereço: ${user.endereco} ',
                          style: TextStyle(fontSize: 10)),
                    )
                  ]));
            },
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                  child: Column(children: [
                    Container(width: double.infinity, height: 3),
                    Row(
                      children: [
                        Text(
                            'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446'),
                      ],
                    ),
                  ]));
            },
            build: (Context context) => <Widget>[
                  Padding(padding: const EdgeInsets.all(10)),
                  Text('Principais doenças genéticas da raça',
                      style: TextStyle(fontSize: 18)),
                  Padding(padding: const EdgeInsets.all(10)),
                  TableHelper.fromTextArray(
                      cellAlignment: pw.Alignment.center,
                      cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5, color: PdfColors.grey),
                            borderRadius:
                                pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                      border: pw.TableBorder(verticalInside: BorderSide.none),
                      context: context,
                      headers: [
                        'Categoria',
                        'Doença',
                        'Gene',
                        'Variante',
                        'Resultado'
                      ],
                      defaultColumnWidth: FixedColumnWidth(200),
                      data: principaisData.sublist(
                          i,
                          i + itemsPerPage > principaisData.length
                              ? principaisData.length
                              : i + itemsPerPage)),
                  Padding(padding: const EdgeInsets.all(10)),
                ]),
      );
    }
    for (int i = 0; i < todasData.length; i += itemsPerPage) {
      pdf.addPage(
        MultiPage(
            crossAxisAlignment: CrossAxisAlignment.start,
            header: (Context context) {
              return Container(
                  margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
                  alignment: Alignment.centerRight,
                  child: Row(children: [
                    pw.Image(pw.MemoryImage(imageData), height: 50),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 400,
                      child: Text(
                          'SAÚDE: Traços e Doenças - Nome do Pet: $name - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} - Registro: ${ativacao.registro} - Microchip: ${ativacao.chip} Nome do Tutor: ${ativacao.nome_cliente} - Endereço: ${user.endereco} ',
                          style: TextStyle(fontSize: 10)),
                    )
                  ]));
            },
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                  child: Column(children: [
                    Container(width: double.infinity, height: 3),
                    Row(
                      children: [
                        Text(
                            'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446'),
                      ],
                    ),
                  ]));
            },
            build: (Context context) => <Widget>[
                  Padding(padding: const EdgeInsets.all(10)),
                  Text('Todas as doenças genéticas avaliadas',
                      style: TextStyle(fontSize: 18)),
                  Padding(padding: const EdgeInsets.all(10)),
                  TableHelper.fromTextArray(
                      cellAlignment: pw.Alignment.center,
                      cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5, color: PdfColors.grey),
                            borderRadius:
                                pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                      border: pw.TableBorder(verticalInside: BorderSide.none),
                      context: context,
                      headers: [
                        'Categoria',
                        'Doença',
                        'Gene',
                        'Variante',
                        'Resultado'
                      ],
                      defaultColumnWidth: FixedColumnWidth(200),
                      data: todasData.sublist(
                          i,
                          i + itemsPerPage > todasData.length
                              ? todasData.length
                              : i + itemsPerPage)),
                  Padding(padding: const EdgeInsets.all(10)),
                ]),
      );
    }
    for (int i = 0; i < traco.length; i += itemsPerPage) {
      pdf.addPage(
        MultiPage(
            crossAxisAlignment: CrossAxisAlignment.start,
            header: (Context context) {
              return Container(
                  margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
                  alignment: Alignment.centerRight,
                  child: Row(children: [
                    pw.Image(pw.MemoryImage(imageData), height: 50),
                    SizedBox(width: 20),
                    SizedBox(
                      width: 400,
                      child: Text(
                          'SAÚDE: Traços e Doenças - Nome do Pet: $name - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} - Registro: ${ativacao.registro} - Microchip: ${ativacao.chip} Nome do Tutor: ${ativacao.nome_cliente} - Endereço: ${user.endereco} ',
                          style: TextStyle(fontSize: 10)),
                    )
                  ]));
            },
            footer: (Context context) {
              return Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
                  child: Column(children: [
                    Container(width: double.infinity, height: 3),
                    Row(
                      children: [
                        Text(
                            'Resultados revisados e confirmados por Dr. Lucas Rodrigues, DVM, MS, PhD, CRMV-SP 15446'),
                      ],
                    ),
                  ]));
            },
            build: (Context context) => <Widget>[
                  Padding(padding: const EdgeInsets.all(10)),
                  Text('Traços', style: TextStyle(fontSize: 18)),
                  Padding(padding: const EdgeInsets.all(10)),
                  TableHelper.fromTextArray(
                      cellAlignment: pw.Alignment.center,
                      cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                            border: pw.Border.all(
                                width: 0.5, color: PdfColors.grey),
                            borderRadius:
                                pw.BorderRadius.all(pw.Radius.circular(5)),
                          ),
                      border: pw.TableBorder(verticalInside: BorderSide.none),
                      context: context,
                      headers: [
                        'Categoria',
                        'Doença',
                        'Gene',
                        'Variante',
                        'Resultado'
                      ],
                      defaultColumnWidth: FixedColumnWidth(200),
                      data: traco.sublist(
                          i,
                          i + itemsPerPage > traco.length
                              ? traco.length
                              : i + itemsPerPage)),
                  Padding(padding: const EdgeInsets.all(10)),
                ]),
      );
    }
    //save PDF
    stopwatch.stop();
    print(
        'Tempo total para gerar PDF: \x1B[32m${stopwatch.elapsedMilliseconds} ms (${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s)\x1B[0m');
    change('Finalizando documento.', true, 99);
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/Resultado_${ativacao.name}.pdf';
    final File file = File(path);

    await file.writeAsBytes(await pdf.save());
    box.write('Resultado_${ativacao.name}.pdf', path);

    if (onComplete != null) {
      onComplete(path);
    } else {
      material.Navigator.of(context).push(
        material.MaterialPageRoute(
          builder: (_) => PdfViwerPage(path: path),
        ),
      );
    }
    change('', true, 0);
  }
}
