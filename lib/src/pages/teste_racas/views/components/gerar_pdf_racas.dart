

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
Future getTesteRaca(String id) async {
  final Response<dynamic> response = await http.dio.get('/app_DNAProfile_marcadores');
  
  final Response<dynamic> responseId =
      await http.dio.get('/app_resultado_raca?filterByFormula=Ativacao="$id"');
  var result = responseId.data['records'][0];

  List<dynamic> listMarcadores = response.data['records'];



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



final box = GetStorage();
reportViwRacas(
  context, {
  
  required AppAtivacaoModel ativacao,
  required Uint8List image,
}) async {//
  final ByteData imageHeader =
      await rootBundle.load('assets/images/logoB4p_centralizado.png');
        Uint8List imageDataHeader = (imageHeader).buffer.asUint8List();

  Uint8List imageData = (image).buffer.asUint8List();

  final pdf = Document();
  pdf.addPage(MultiPage(
      crossAxisAlignment: CrossAxisAlignment.start,
      header: (Context context) {
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            child: Row(children: [
              pw.Image(pw.MemoryImage(imageDataHeader), height: 50),
              SizedBox(width: 20),
              SizedBox(
                width: 400,
                child: Text(
                    'ORIGEM: Teste de identificação de raça - Nome do Pet: ${ativacao.name} - Número do Swab: ${ativacao.Case_ID} Nasc.: ${ativacao.nascimento} Espécie: ${ativacao.especie} - Raça: ${ativacao.raca} Nome do Tutor: ${ativacao.nome_cliente} ',
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
           Container(
            padding: const EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color:  PdfColor.fromHex('#3e2e75'), width: 2),
            
            ),
            child: Text(
              'ORIGEM - TESTE GENÉTICO DE IDENTIFICAÇÃO DE RAÇA',
              style: TextStyle(
                fontSize: 16,
                color: PdfColor.fromHex('#3e2e75'),
                fontWeight: FontWeight.bold,
              ),
            ),
           ),
            Padding(padding: const EdgeInsets.all(10)),
          Text('Utilizando o teste de DNA e uma análise algorítmica podemos identificar a composição de raças do(a) ${ativacao.name}', style: TextStyle(fontSize: 14, color: PdfColor.fromHex('#3e2e75') ),),
            SizedBox(height: 20),
            Center(
              child: pw.Image(
                pw.MemoryImage(imageData),
                height: 360,
                fit: pw.BoxFit.contain,
              ),
            ),
            pw.NewPage(),
            Padding(padding: const EdgeInsets.all(10)),
            Text('Sobre o Painel Origem', style: TextStyle(fontSize: 16, color: PdfColor.fromHex('#3e2e75'), fontWeight: FontWeight.bold),),
            Text('Esse teste avalia a ancestralidade do seu cão em relação a algumas raças puras específicas, voltando três gerações. No entanto, pode haver uma porcentagem do genoma que ainda não foi caracterizada ou relacionada a nenhuma raça conhecida, sendo descrita como raça indeterminada. Uma maior porcentagem de genoma ainda não identificado pode ocorrer em países onde a genotipagem canina ainda está em estágio inicial, como no Brasil.',  style: TextStyle(fontSize: 14, color: PdfColor.fromHex('#3e2e75')),),
            Padding(padding: const EdgeInsets.all(10)),
            Text('Além disso, é importante notar que qualquer raça que tenha menos de 10% não representa pais ou avós, mas sim as raças formadoras deles. Essas raças formadoras são chamadas de raças ascendentes e não têm influência na definição de características físicas e tendências de comportamento. Dessa forma, os cães de raça pura também podem apresentar em sua composição raças ascendentes.',  style: TextStyle(fontSize: 14, color: PdfColor.fromHex('#3e2e75')),),
            Text('Grupo dos cães de acordo com a classificação da Federação Cinológica Internacional (FCI).', style: TextStyle(fontSize: 11, color: PdfColor.fromHex('#3e2e75'),),),
          ]));
  //save PDF

  final String dir = (await getApplicationDocumentsDirectory()).path;
  final String path = '$dir/Teste_Raca_${ativacao.name}.pdf';
  final File file = File(path);

  await file.writeAsBytes(await pdf.save());

  material.Navigator.of(context).push(
    material.MaterialPageRoute(
      builder: (_) => PdfViwerPage(path: path),
    ),
  );

}
