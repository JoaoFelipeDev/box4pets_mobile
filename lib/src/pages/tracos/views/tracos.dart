// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/tracos/bloc/tracos_bloc.dart';
import 'package:Box4Pets/src/pages/tracos/models/tracos_model.dart';

import 'components/tracos_resumo_component.dart';

class Tracos extends StatefulWidget {
  final String id;
  final String especie;
  final String box;
  final String subTitle;
  const Tracos({
    Key? key,
    required this.id,
    required this.especie,
    required this.box,
    required this.subTitle,
  }) : super(key: key);

  @override
  _TracosState createState() => _TracosState();
}

class _TracosState extends State<Tracos> {
  bool result = false;
  final http = EndpointDio();
  List<String> resultadoValor = [];
  Future resultado(List<TracosModel> marcador) async {
    for (var element in marcador) {
      final Response<dynamic> response = await http.dio.get(
          '/app_resultado_saude_cao?filterByFormula=app_ativacao="${widget.box}"');

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

  late final TracosBloc _tracosBloc;
  @override
  void initState() {
    _tracosBloc = TracosBloc();
    _tracosBloc.add(TracosGetEvent(id: widget.id, especie: widget.especie));

    super.initState();
  }

  Widget build(BuildContext context) {
    return BlocListener<TracosBloc, TracosState>(
      bloc: _tracosBloc,
      listener: (context, state) {
        if (state is TracosLoaded) {
          resultado(state.tracos);
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: SafeArea(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 131,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Traços',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: Color(0xff600499)),
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
        body: BlocBuilder<TracosBloc, TracosState>(
          bloc: _tracosBloc,
          builder: (context, state) {
            if (state is TracosLoaded) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        widget.id,
                        style: const TextStyle(
                            color: Color(0xff600499),
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        widget.subTitle,
                        style: const TextStyle(
                            color: Color(0xff600499),
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: 1000,
                        child: ListView.builder(
                          itemCount: state.tracos.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TracosResumoComponent(
                                        resultado: resultadoValor[index],
                                        tracos: state.tracos[index],
                                        id: widget.id,
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
                                  title: Text(state.tracos[index].traco),
                                  subtitle: Text(
                                    result
                                        ? resultadoValor[index]
                                        : 'Aguardando resultado...',
                                    style: TextStyle(
                                      color: result ? Colors.red : Colors.blue,
                                    ),
                                  ),
                                  trailing: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TracosResumoComponent(
                                              resultado: resultadoValor[index],
                                              tracos: state.tracos[index],
                                              id: widget.id,
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
                      )
                    ],
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
