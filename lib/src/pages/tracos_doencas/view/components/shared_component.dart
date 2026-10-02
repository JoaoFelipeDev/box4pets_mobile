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

Future<List<dynamic>> _fetchCatalogPages(
  String path, {
  bool useView = true,
}) async {
  final all = <dynamic>[];
  String? offset;
  do {
    final params = <String, dynamic>{
      'sort[0][field]': 'Categoria',
      'sort[0][direction]': 'asc',
      if (offset != null) 'offset': offset,
    };
    final query = useView ? airtableCatalogParams(params) : params;
    final response = await http.dio.get(
      path,
      queryParameters: query,
      options: Options(
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    all.addAll(response.data['records'] as List? ?? const []);
    offset = response.data['offset'];
  } while (offset != null);
  return all;
}

Future getTracos() async {
  try {
    return await _fetchCatalogPages('/app_lista_tracos');
  } catch (_) {
    return _fetchCatalogPages('/app_lista_tracos', useView: false);
  }
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
  } while (offset != null);

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

const _kSentinelIds = {'recjDN4RRnRMIm9Ec', 'rec0WXP3glPAbosku'};

String _textoCampo(dynamic raw) {
  if (raw == null) return '';
  return raw.toString();
}

String _resultadoMarcador(Map<String, dynamic>? saude, dynamic marcador) {
  final key = _textoCampo(marcador);
  if (saude == null || key.isEmpty || key == '-') return '';
  return _textoCampo(saude[key]);
}

ListDoencasPdfModel _doencaDoCatalogo(
    Map record, Map<String, dynamic>? saude) {
  final rawFields = record['fields'];
  final fields = rawFields is Map
      ? Map<String, dynamic>.from(rawFields)
      : <String, dynamic>{};
  return ListDoencasPdfModel(
    marcador: _textoCampo(fields['Marcador']),
    categoria: _textoCampo(fields['Categoria']),
    doenca: _textoCampo(fields['Doença']),
    gene: _textoCampo(fields['Gene']),
    variante: _textoCampo(fields['Variante']),
    resultado: _resultadoMarcador(saude, fields['Marcador']),
  );
}

Future<Map<String, dynamic>?> _fetchSaudeCaoOnce(String caseId) async {
  final response = await http.dio.get(
      '/app_resultado_saude_cao?filterByFormula=app_ativacao="$caseId"');
  final records = response.data['records'] as List? ?? [];
  if (records.isEmpty) return null;
  return Map<String, dynamic>.from(records.first['fields'] as Map);
}

List<ListDoencasPdfModel> _doencasPorIds(
  List<String> ids,
  Map<String, Map<String, dynamic>> catalogById,
  Map<String, dynamic>? saude,
) {
  final out = <ListDoencasPdfModel>[];
  for (final id in ids) {
    if (_kSentinelIds.contains(id)) continue;
    final record = catalogById[id];
    if (record == null) continue;
    final item = _doencaDoCatalogo(record, saude);
    if (!item.isPlaceholder) out.add(item);
  }
  return out;
}

reportView(
  context, {
  required void Function(String change, bool close, int progress) change,
  required List<String> umaVariate,
  required List<String> duasVariantes,
  required List<String> principais,
  required List<String> todas,
  required int totalGenes,
  required int livres,
  required int portadores,
  required int risco,
  required int variantesRelevantesRaca,
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

  change('Buscando resultados do exame', false, 5);
  final saudeFields = await _fetchSaudeCaoOnce(ativacao.Case_ID);
  change('Buscando catálogo de doenças', false, 20);
  final catalogo = ativacao.especie == "Felina"
      ? await getTodasDoencasGato()
      : await getTodasDoencas();
  final catalogById = <String, Map<String, dynamic>>{};
  for (final raw in catalogo) {
    if (raw is Map<String, dynamic> && raw['id'] is String) {
      catalogById[raw['id'] as String] = raw;
    } else if (raw is Map && raw['id'] is String) {
      catalogById[raw['id'] as String] = Map<String, dynamic>.from(raw);
    }
  }

  change('Montando listas do relatório', false, 45);
  uma_variante = _doencasPorIds(umaVariate, catalogById, saudeFields);
  duas_variante = _doencasPorIds(duasVariantes, catalogById, saudeFields);
  duas_variante.sort((a, b) => a.categoria.compareTo(b.categoria));
  principais_caracteristicas =
      _doencasPorIds(principais, catalogById, saudeFields);
  principais_caracteristicas.sort((a, b) => a.categoria.compareTo(b.categoria));

  change('Buscando traços', false, 65);
  List<dynamic> resultTracos = const [];
  try {
    resultTracos = ativacao.especie == "Felina"
        ? await getTracosGatos()
        : await getTracos();
  } catch (_) {}
  tracos = resultTracos.map((element) {
    final fields = Map<String, dynamic>.from(
        (element['fields'] as Map?) ?? const {});
    return ListTracosPdf(
      marcador: _textoCampo(fields['Marcador']),
      categoria: _textoCampo(fields['Categoria']),
      tracos: _textoCampo(fields['Traço']),
      gene: _textoCampo(fields['Gene1']),
      variante: _textoCampo(fields['Variante']),
      resultado: _resultadoMarcador(saudeFields, fields['Marcador']),
    );
  }).toList();

  change('Montando todas as doenças avaliadas', false, 80);
  try {
    for (final raw in catalogo) {
      if (raw is! Map) continue;
      final item = _doencaDoCatalogo(raw, saudeFields);
      if (!item.isPlaceholder && item.marcador != '-') {
        todas_doencas.add(item);
      }
    }
  } catch (_) {}

  change('Montando o relatório', false, 95);
  try {
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
      totalGenes: totalGenes,
      livres: livres,
      portadores: portadores,
      risco: risco,
      variantesRelevantesRaca: variantesRelevantesRaca,
    );

    stopwatch.stop();
    print(
        'Tempo total para gerar PDF: ${stopwatch.elapsedMilliseconds} ms');
    change('Finalizando documento.', true, 99);
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/Resultado_${ativacao.name}.pdf';
    final File file = File(path);

    await file.writeAsBytes(pdfBytes);
    box.write('Resultado_v10_${ativacao.name}.pdf', path);

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
  } catch (_) {
    change('Erro ao montar o relatório', true, 0);
  }
}
