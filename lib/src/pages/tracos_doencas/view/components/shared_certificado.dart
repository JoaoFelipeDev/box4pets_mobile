import 'dart:convert';

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
    final Response<dynamic> response = await  http.dio.get(
      '/app_lista_doenca',
      queryParameters: queryParameters,
    );

    // Adiciona os registros à lista final
    allRecords.addAll(response.data['records']);

    // Atualiza o offset, se houver mais itens
    offset = response.data['offset'];
    print('total : ${allRecords.length}');
  } while (offset != null);  // Continua enquanto houver um offset

  return allRecords;
}


Future getTodasDoencasGato() async {
  final Response<dynamic> response = await http.dio.get(
      '/app_lista_doenca_gato?sort%5B0%5D%5Bfield%5D=Categoria&sort%5B0%5D%5Bdirection%5D=asc');
  return response.data['records'];
}

final box = GetStorage();
reportViewCertificado(
  context, {
  required Function stopLoading,
  required List<String> principais,
  required String name,
  required AppAtivacaoModel ativacao,
  void Function(int current, int total)? onProgress,
  void Function(String path)? onComplete,
}) async {
  String json = box.read('user');
  UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
  List<ListDoencasPdfModel> uma_variante = [];

  List<ListDoencasPdfModel> duas_variante = [];
  List<ListDoencasPdfModel> principais_caracteristicas = [];
  List<ListDoencasPdfModel> todas_doencas = [];
  List<ListTracosPdf> tracos = [];

  onProgress?.call(0, principais.length);

  for (int i = 0; i < principais.length; i++) {
    final element = principais[i];
    String result = "";

    Map<String, dynamic> map = {};
    if (ativacao.especie == "Felina") {
      map = await getDoencasGato(element);
    } else {
      map = await getDoencas(element);
    }
    final Response<dynamic> response = await http.dio.get(
        '/app_resultado_saude_cao?filterByFormula=app_ativacao="${ativacao.Case_ID}"');

    if ((response.data['records'] as List).isNotEmpty) {
      result = response.data['records'][0]['fields'][map['fields']['Marcador']];
    }

    principais_caracteristicas.add(
      ListDoencasPdfModel(
          marcador: map['fields']['Marcador'] ?? '',
          categoria: map['fields']['Categoria'] ?? '',
          doenca: map['fields']['Doença'] ?? '',
          gene: map['fields']['Gene'] ?? '',
          variante: map['fields']['Variante'] ?? '',
          resultado: result),
    );
    principais_caracteristicas
        .sort((a, b) => a.categoria.compareTo(b.categoria));
    onProgress?.call(i + 1, principais.length);
  }
  

 
  


  final principaisData = principais_caracteristicas
      .map((e) => [e.categoria, e.doenca, e.gene, e.variante, e.resultado])
      .toList();
 

  final ByteData image =
      await rootBundle.load('assets/images/logoB4p_centralizado.png');

  Uint8List imageData = (image).buffer.asUint8List();
  
  int itemsPerPage = 20;
  final pdf = Document();
  // for de umaVarianteData

    
  
  
    pdf.addPage(
    MultiPage(
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          return Container(
              margin: const EdgeInsets.only(bottom: 1.0 * PdfPageFormat.cm),
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                pw.Image(pw.MemoryImage(imageData), height: 50),
                Padding(padding: const EdgeInsets.all(10)),
                SizedBox(width: 20),
                pw.Center(
                  child: Text(
                  textAlign: TextAlign.center,
                  'CERTIFICADO DE ANÁLISE GENÉTICA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PdfColor(63 / 255, 40 / 255, 115 / 255))),
                ),
                Padding(padding: const EdgeInsets.all(10)),
                pw.Center(
                  child:  Text(
                  textAlign: TextAlign.center,
                  'Certificamos que',
                    style: TextStyle(fontSize: 16, color: PdfColors.black)),
                ),
                Padding(padding: const EdgeInsets.all(10)),
                pw.Center(
                  child: Text(
                  textAlign: TextAlign.center,
                  '${ativacao.name}',
                    style: TextStyle(fontSize: 16, color: PdfColors.black)),
                ),
                Padding(padding: const EdgeInsets.all(10)),
                pw.Center(
                  child: Text(
                  textAlign: TextAlign.center,
                  '${ativacao.especie}, ${ativacao.sexo}, ${ativacao.raca}, nascido(a) em ${ativacao.nascimento}, SWAB: ${ativacao.swab}, Tutor: ${ativacao.nome_cliente} Registro: ${ativacao.registro}, Microchip: ${ativacao.chip}',
                    style: TextStyle(fontSize: 16, color: PdfColors.black)),
                ),
                Padding(padding: const EdgeInsets.all(10)),
                pw.Center(
                  child: Text(
                  textAlign: TextAlign.center,
                  'Realizou o teste genético para avaliação de doenças genéticas, traços e perfil de DNA. Mais de 200 marcadores foram avaliados e abaixo apresentamos um resumo dos resultados das doenças genéticas relevantes à raça. Verifique o resultado completo do teste pelo aplicativo.',
                    style: TextStyle(fontSize: 16, color: PdfColors.black)),
                ),
               
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
              
                Padding(padding: const EdgeInsets.all(10)),
              Text('Principais doenças genéticas da raça', style: TextStyle(fontSize: 18)),
              
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
                  data: principaisData),
              Padding(padding: const EdgeInsets.all(10)),
              
            ]
            ),
  );
  
  
  
  //save PDF

  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/Certificado_${ativacao.name}.pdf';
  final File file = File(path);

  await file.writeAsBytes(await pdf.save());
  box.write('Certificado_${ativacao.name}.pdf', path);
  stopLoading();
  if (onComplete != null) {
    onComplete(path);
  } else {
    material.Navigator.of(context).push(
      material.MaterialPageRoute(
        builder: (_) => PdfViwerPage(path: path),
      ),
    );
  }
}

