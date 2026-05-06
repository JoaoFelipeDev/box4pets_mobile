import 'dart:convert';
import 'package:Box4Pets/http/endpoint_dio.dart';
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
import '../../../home/models/app_ativacao_model.dart';


final http = EndpointDio();
List<List<dynamic>> listDataTable = [];
Future getDNA(String id) async {
List<dynamic> allRecords = [];
String? offset;
  do{
    final queryParameters = {
      if (offset != null) 'offset': offset,
    };
    final Response<dynamic> response = await http.dio.get(
      '/app_DNAProfile_marcadores',
      queryParameters: queryParameters,
    );
    allRecords.addAll(response.data['records']);
    offset = response.data['offset'];
  }while (offset != null);

  final Response<dynamic> response = await http.dio.get('/app_DNAProfile_marcadores');
  final Response<dynamic> responseId = await http.dio.get('/app_DNAProfile_resultado?filterByFormula=ID_BOX="$id"');
  
  var result = responseId.data['records'][0];
  List<dynamic> listMarcadores = allRecords;
  print('dna: ${listMarcadores.length}');
  for (var element in listMarcadores) {
    if(result['fields'][element['fields']['Marcador']] != null){
      listDataTable.add([
      element['fields']['Marcador_ISAG'],
      result['fields'][element['fields']['Marcador'] ?? '-'],
    ]);
    }
  }
  return response.data['records'][0];
}

// Future<List<dynamic>> getDNA(String id) async {
//   List<dynamic> allRecords = [];
//   String? offset;

//   // Loop para buscar todas as páginas
//   do {
//     final queryParameters = {
//       'filterByFormula': 'ID_BOX="$id"',
//       if (offset != null) 'offset': offset,
//     };

//     // Realiza a requisição com ou sem o offset
//     final Response<dynamic> response = await http.dio.get(
//       '/app_DNAProfile_resultado',
//       queryParameters: queryParameters,
//     );

//     // Adiciona os registros à lista final
//     allRecords.addAll(response.data['records']);

//     // Atualiza o offset, se houver mais itens
//     offset = response.data['offset'];
//   } while (offset != null);  // Continua enquanto houver um offset

//   // Obtém os marcadores
//   final Response<dynamic> responseMarcadores = await http.dio.get('/app_DNAProfile_marcadores');
//   List<dynamic> listMarcadores = responseMarcadores.data['records'];

//   // Processa os dados
//   List<List<dynamic>> listDataTable = [];
//   for (var element in listMarcadores) {
//     for (var result in allRecords) {
//       if (result['fields'][element['fields']['Marcador']] != null) {
//         listDataTable.add([
//           element['fields']['Marcador_ISAG'],
//           result['fields'][element['fields']['Marcador']] ?? '-',
//         ]);
//       }
//     }
//   }

//   return listDataTable;
// }


final box = GetStorage();
reportViewDNA(
  context, {
  
  required AppAtivacaoModel ativacao,
}) async {
  
  

 
await getDNA(ativacao.swab);

  

  final ByteData image =
      await rootBundle.load('assets/images/logoB4p_centralizado.png');

  Uint8List imageData = (image).buffer.asUint8List();

  final pdf = Document();
  pdf.addPage(MultiPage(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            // decoration: BoxDecoration(
                
            //     border: Border.all(width: 0.5, color: PdfColors.grey)),
            child: Row(children: [
              pw.Image(pw.MemoryImage(imageData), height: 50),
              SizedBox(width: 20),
              SizedBox(
                width: 400,
                child: Text(
                    'DNA: Perfil DNA - Nome do Pet: ${ativacao.name} - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} ',
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
            Text('Perfil DNA', style: TextStyle(fontSize: 18)),
            TableHelper.fromTextArray(
              cellAlignment: pw.Alignment.center,
              cellDecoration: (index, data, rowNum) => pw.BoxDecoration(
                border: pw.Border.all(width: 0.5, color: PdfColors.grey),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
              ),
              
              border: pw.TableBorder(

                verticalInside: BorderSide.none
              ),
                context: context,
                headers: [
                 'Marcador',
                 'Tipo Gene',
                ],
                defaultColumnWidth: FixedColumnWidth(200),
                data: listDataTable),
            Padding(padding: const EdgeInsets.all(10)),
            
          ]));
  //save PDF

  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/Perdil_DNA_${ativacao.name}.pdf';
  final File file = File(path);

  await file.writeAsBytes(await pdf.save());

  material.Navigator.of(context).push(
    material.MaterialPageRoute(
      builder: (_) => PdfViwerPage(path: path),
    ),
  );

}
