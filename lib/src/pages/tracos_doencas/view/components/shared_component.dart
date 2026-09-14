import 'dart:convert';
import 'dart:async';

import 'package:Box4Pets/http/airtable_catalog_view.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/models/list_tracos_pdf.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_viwer_page.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/resultado_saude_pdf.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
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
    '/app_lista_doenca',
    queryParameters: airtableCatalogParams({
      'filterByFormula': 'Marcador="$result"',
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    }),
  );
  return response.data['records'][0];
}

Future getDoencasGato(String id) async {
  final Response<dynamic> responseId =
      await http.dio.get('/app_lista_doenca_gato/$id');
  print('responseId: $responseId');
  var result = responseId.data['fields']['Marcador'];
  final Response<dynamic> response = await http.dio.get(
    '/app_lista_doenca_gato',
    queryParameters: airtableCatalogParams({
      'filterByFormula': 'Marcador="$result"',
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    }),
  );
  return response.data['records'][0];
}

Future getTracos() async {
  final Response<dynamic> response = await http.dio.get(
    '/app_lista_tracos',
    queryParameters: airtableCatalogParams({
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    }),
  );
  return response.data['records'];
}

Future getTracosGatos() async {
  final Response<dynamic> response = await http.dio.get(
    '/app_lista_tracos_gato',
    queryParameters: airtableCatalogParams({
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    }),
  );
  return response.data['records'];
}

Future<List<dynamic>> getTodasDoencas() async {
  List<dynamic> allRecords = [];
  String? offset;

  // Loop para buscar todas as páginas
  do {
    final queryParameters = airtableCatalogParams({
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
      if (offset != null) 'offset': offset,
    });

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
    '/app_lista_doenca_gato',
    queryParameters: airtableCatalogParams({
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
    }),
  );
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
  List<dynamic> result = ativacao.especie == "Felina"
      ? await getTodasDoencasGato()
      : await getTodasDoencas();
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

  change('Montando o relatório', false, 95);
  final ByteData image =
      await rootBundle.load('assets/images/logoB4p_centralizado.png');
  final pdfBytes = await buildResultadoSaudePdf(
    logoBytes: image.buffer.asUint8List(),
    name: name,
    ativacao: ativacao,
    user: user,
    umaVariante: uma_variante,
    duasVariante: duas_variante,
    principais: principais_caracteristicas,
    todas: todas_doencas,
    tracos: tracos,
  );

  stopwatch.stop();
  print(
      'Tempo total para gerar PDF: \x1B[32m${stopwatch.elapsedMilliseconds} ms (${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s)\x1B[0m');
  change('Finalizando documento.', true, 99);
  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/Resultado_${ativacao.name}.pdf';
  final File file = File(path);

  await file.writeAsBytes(pdfBytes);
  box.write('Resultado_v4_${ativacao.name}.pdf', path);

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
