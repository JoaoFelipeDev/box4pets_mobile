// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/models/app_lista_doencas_model.dart';

import 'doenca_completa_component.dart';

class ResumoDoencaComponent extends StatefulWidget {
  final List<AppListaDoencasModel> doenca;
  final String box;
  final String categoria;
  final String especies;

  const ResumoDoencaComponent({
    Key? key,
    required this.doenca,
    required this.box,
    required this.categoria,
    required this.especies,
  }) : super(key: key);

  @override
  State<ResumoDoencaComponent> createState() => _ResumoDoencaComponentState();
}

class _ResumoDoencaComponentState extends State<ResumoDoencaComponent> {
  final http = EndpointDio();
  List<String> resultadoValor = [];
  bool result = false;

  Future resultado(List<AppListaDoencasModel> marcador) async {
    for (var element in marcador) {
      final Response<dynamic> response = await http.dio.get(
          '/app_resultado_saude_cao?filterByFormula=app_ativacao="${widget.box}"');
        
        print('response: ${widget.box}');

      if ((response.data['records'] as List).isNotEmpty) {
        String? result =
            response.data['records'][0]['fields'][element.marcador];
        setState(() {
          if (result != null) {
            resultadoValor.add(result);
          } else {
            resultadoValor.add('');
          }
        });
      }
    }
    setState(() {
      result = true;
    });
  }

  @override
  void initState() {
    resultado(widget.doenca);
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(200),
        child: SafeArea(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 131,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 250,
                  child: Text(
                    widget.categoria,
                    style:  TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: AppColor.primary),
                  ),
                ),
                const SizedBox(
                  width: 70,
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xff00D4C5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColor.primary,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: widget.doenca.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: 15,
          ),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoencaCompletaComponent(
                        doenca: widget.doenca[index],
                        resultado: resultadoValor[index],
                      ),
                    ));
              },
              child: Card(
                elevation: 5,
                child: ListTile(
                  leading: Icon(
                    Icons.remove_circle,
                    color: AppColor.primary,
                  ),
                  title: Text(
                    '${widget.doenca[index].doenca} (${widget.doenca[index].gene})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    result ? resultadoValor[index] : 'Verificando resultado...',
                    style: TextStyle(
                        color: result ? Colors.red : Colors.blue, fontSize: 18),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoencaCompletaComponent(
                              doenca: widget.doenca[index],
                              resultado: resultadoValor[index],
                            ),
                          ));
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
