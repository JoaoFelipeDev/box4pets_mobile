// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/bloc/doencas_uma_variante_bloc.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/views/components/resumo_doenca_component.dart';

class DoencasUmaVariante extends StatefulWidget {
  final List<String> id;
  final String title;
  final String especie;
  final String box;
  const DoencasUmaVariante({
    Key? key,
    required this.id,
    required this.title,
    required this.especie,
    required this.box,
  }) : super(key: key);

  @override
  _DoencasUmaVarianteState createState() => _DoencasUmaVarianteState();
}

class _DoencasUmaVarianteState extends State<DoencasUmaVariante> {
  late final DoencasUmaVarianteBloc _doencasUmaVarianteBloc;
  @override
  void initState() {
    _doencasUmaVarianteBloc = DoencasUmaVarianteBloc();
    _doencasUmaVarianteBloc.add(
        DoencasUmaVarianteGetEvent(id: widget.id, especie: widget.especie));
    super.initState();
  }

  @override
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
                      widget.title,
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
          child: BlocBuilder<DoencasUmaVarianteBloc, DoencasUmaVarianteState>(
            bloc: _doencasUmaVarianteBloc,
            builder: (context, state) {
              if (state is DoencasUmaVarianteLoaded) {
                return ListView.builder(
                  itemCount: state.categorias.length,
                  itemBuilder: (context, index) => InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResumoDoencaComponent(
                              doenca: state.doenca
                                  .where((element) =>
                                      element.categoria ==
                                      state.categorias[index])
                                  .toList(),
                              categoria: state.categorias[index],
                              box: widget.box,
                              especies: widget.especie,
                            ),
                          ));
                    },
                    child: state.categorias[index] ==
                            'Nenhuma Variante Identificada'
                        ? Container(
                            child: Center(
                              child: Text('Nenhuma Variante Identificada'),
                            ),
                          )
                        : Card(
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: Text(state.categorias[index]),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ResumoDoencaComponent(
                                          doenca: state.doenca
                                              .where((element) =>
                                                  element.categoria ==
                                                  state.categorias[index])
                                              .toList(),
                                          categoria: state.categorias[index],
                                          box: widget.box,
                                          especies: widget.especie,
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
                  ),
                );
              } else if (state is DoencasUmaVarianteLoading) {
                return const Center(
                  child: Column(
                    children: [Box4PetsLoader(), Text('Aguarde um momento...')],
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ));
  }
}
