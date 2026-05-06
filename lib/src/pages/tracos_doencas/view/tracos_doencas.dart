// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:Box4Pets/src/pages/parentesco/views/parentesco_screen.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/loading_page_pdf.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_perfil_dna.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_viwer_page.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/shared_certificado.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/views/doencas_uma_variante.dart';
import 'package:Box4Pets/src/pages/tracos/views/tracos.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/bloc/tracos_doencas_bloc.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/shared_component.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


import '../../home/models/app_ativacao_model.dart';

class TracosDoencas extends StatefulWidget {
  final String box;
  final String name;
  final String? url;
  final AppAtivacaoModel ativacao;
 
  const TracosDoencas({
    Key? key,
    required this.box,
    required this.name,
    required this.url,
    required this.ativacao,
  }) : super(key: key);

  @override
  State<TracosDoencas> createState() => _TracosDoencasState();
}

class _TracosDoencasState extends State<TracosDoencas> {
   bool isCertificado = false;
  late final TracosDoencasBloc _tracosDoencasBloc;
  List<String> doenca_uma_variante = [];
  List<String> doenca_duas_variante = [];
  List<String> principais = [];
  List<String> todas = [];
  bool sharedLoad = false;
  final box = GetStorage();
  int progress = 0;
  @override
  void initState() {
    _tracosDoencasBloc = TracosDoencasBloc();
    _tracosDoencasBloc.add(TracosDoencasGetEvent(box: widget.box));
    super.initState();
  }

  dispose(){
    _tracosDoencasBloc.close();
    setState(() {
      sharedLoad = false;
      progress = 0;
      status = '';
    });
    super.dispose();
  }

  String status = '';

  void changeStatus(String change, bool close, int progres) {
    setState(() {
      status = change;
      progress = progres;
    });
    
  }

  stopLoading() {
    setState(() {
      isCertificado = false;
    });
  }

  openModal() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  ElevatedButton(onPressed: (){}, child: Text('Gerar novo relatório')),	
                  ElevatedButton(onPressed: (){}, child: Text('Usar relatório anterior')),	
                  ElevatedButton(onPressed: (){}, child: Text('Cancelar')),	
                ],

              ),
            ),
          ],
        ),
      )
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 131,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                    onTap: () => Navigator.popAndPushNamed(context, '/base'),
                    child: Image.asset('assets/images/logo_tracos.png')),
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
      body: BlocListener<TracosDoencasBloc, TracosDoencasState>(
        bloc: _tracosDoencasBloc,
        listener: (context, state) {
          if (state is TracosDoencasLoaded) {
            setState(() {
              doenca_uma_variante = state.tracosDoencas.uma_variante;
              doenca_duas_variante = state.tracosDoencas.duas_variante;
              principais =
                  state.tracosDoencas.principais_doencas_geneticas_da_raca;
              todas = state.tracosDoencas.todas_doencas_geneticas_avaliadas;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BlocBuilder<TracosDoencasBloc, TracosDoencasState>(
                          bloc: _tracosDoencasBloc,
                          builder: (context, state) {
                            if (state is TracosDoencasLoaded) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          border: Border.all(
                                              width: 2, color: Colors.white30)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 20),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              child: widget.url == null
                                                  ? Image.asset(
                                                      'assets/images/cachorro1_solto 1.png',
                                                      fit: BoxFit.fill,
                                                      height: double.infinity,
                                                    )
                                                  : Image.network(widget.url!),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                widget.name,
                                                style: TextStyle(
                                                    color: AppColor.primary,
                                                    fontSize: 21,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            if(box.read('Resultado_${widget.ativacao.name}.pdf') == null){
                                              reportView(context,
                                                change: changeStatus,
                                                ativacao: widget.ativacao,
                                                duasVariantes: state
                                                    .tracosDoencas
                                                    .duas_variante,
                                                principais: state.tracosDoencas
                                                    .principais_doencas_geneticas_da_raca,
                                                todas: state.tracosDoencas
                                                    .todas_doencas_geneticas_avaliadas,
                                                umaVariate: state
                                                    .tracosDoencas.uma_variante,
                                                name: widget.name);
                                            }else{
                                              showDialog(
                                                    context: context,
                                                    builder: (contextDialog) => AlertDialog(
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Center(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                              children: [
                                                                
                                                                ElevatedButton(onPressed: (){
                                                                  Navigator.pop(context);
                                                                  reportView(context,
                                                change: changeStatus,
                                                ativacao: widget.ativacao,
                                                duasVariantes: state
                                                    .tracosDoencas
                                                    .duas_variante,
                                                principais: state.tracosDoencas
                                                    .principais_doencas_geneticas_da_raca,
                                                todas: state.tracosDoencas
                                                    .todas_doencas_geneticas_avaliadas,
                                                umaVariate: state
                                                    .tracosDoencas.uma_variante,
                                                name: widget.name);
                                                                }, child: Text('Gerar novo relatório')),	
                                                                ElevatedButton(onPressed: (){
                                                                  Navigator.pop(context);
                                                                  String path = box.read('Resultado_${widget.ativacao.name}.pdf');
                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViwerPage(path:path),),);
                                                                }, child: Text('Usar relatório anterior')),	
                                                                ElevatedButton(onPressed: (){
                                                                  Navigator.pop(context);
                                                                }, child: Text('Cancelar')),	
                                                              ],

                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  );
                                              // String path = box.read('Resultado_${widget.ativacao.name}.pdf');
                                              //   Navigator.push(context, MaterialPageRoute(builder: (context) => PdfViwerPage(path:path),),);
                                            }
                                            // openModalLoading();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 22),
                                            height: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: const Color.fromRGBO(
                                                    96, 4, 153, 0.72)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                sharedLoad
                                                    ? Box4PetsLoader()
                                                    : Icon(
                                                        Icons
                                                            .ios_share_outlined,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  'Compartilhar \n todo o resultado',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            } else if (state is TracosDoencasLoading) {
                              return Center(
                                child: Box4PetsLoader(),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                        progress <= 0
                            ? Container()
                            : LinearProgressIndicator(
                                value: progress.toDouble() / 100,
                                backgroundColor: Colors.white,
                                valueColor:  AlwaysStoppedAnimation<Color>(
                                    AppColor.primary),
                              ),
                        status.isNotEmpty
                            ? Text('O relatório contém um grande número de genes que foram examinados. Este processo ocorrerá apenas uma vez. Aguarde um momento e acompanhe a evolução. O relatório está ${progress}% concluído.')
                            : Container(),
                        Text(status),

                        const SizedBox(
                          height: 12,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Análise do DNA',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            textAlign: TextAlign.center,
                            'Realizamos uma minuciosa análise do DNA com o objetivo de avaliar o potencial risco para o desenvolvimento de diversas doenças genéticas e traços físicos.',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 21,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            textAlign: TextAlign.center,
                            'Veja no quadro abaixo o número de genes relacionados a doenças e traços relevantes a raça.',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 21,
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 19),
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(4, 213, 198, 1),
                                borderRadius: BorderRadius.circular(30)),
                            child: BlocBuilder<TracosDoencasBloc,
                                TracosDoencasState>(
                              bloc: _tracosDoencasBloc,
                              builder: (context, state) {
                                if (state is TracosDoencasLoaded) {
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 2,
                                                  color: Colors.white30),
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Raio de borda desejado
                                            ),
                                            color: const Color.fromRGBO(
                                                4, 213, 198, 1),
                                            elevation: 3,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.all(30),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${state.tracosDoencas.genes_sem_alteracao}',
                                                      style: TextStyle(
                                                          color: AppColor.primary,
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      textAlign: TextAlign.center,
                                                      'Genes sem alteração relevantes a raça',
                                                      style: TextStyle(
                                                        color: AppColor.primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 2,
                                                  color: Colors.white30),
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Raio de borda desejado
                                            ),
                                            color: const Color.fromRGBO(
                                                4, 213, 198, 1),
                                            elevation: 3,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.all(30),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${state.tracosDoencas.gene_com_uma_variante_detectada}',
                                                      style: TextStyle(
                                                          color: AppColor.primary,
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      textAlign: TextAlign.center,
                                                      'Portador de uma variante. Sem risco aumentado de doença',
                                                      style: TextStyle(
                                                        color: AppColor.primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 2,
                                                  color: Colors.white30),
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Raio de borda desejado
                                            ),
                                            color: const Color.fromRGBO(
                                                4, 213, 198, 1),
                                            elevation: 3,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.all(30),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${state.tracosDoencas.gene_com_duas_variante_detectada}',
                                                      style: TextStyle(
                                                          color: AppColor.primary,
                                                          fontSize: 36,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      textAlign: TextAlign.center,
                                                      'Risco aumentado de doença: duas variantes detectadas',
                                                      style: TextStyle(
                                                        color: AppColor.primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 2,
                                                  color: Colors.white30),
                                              borderRadius: BorderRadius.circular(
                                                  15.0), // Raio de borda desejado
                                            ),
                                            color: const Color.fromRGBO(
                                                4, 213, 198, 1),
                                            elevation: 3,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              margin: const EdgeInsets.all(30),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '${state.tracosDoencas.tracos}',
                                                    style: TextStyle(
                                                        color: AppColor.primary,
                                                        fontSize: 36,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    'Traços',
                                                    style: TextStyle(
                                                      color: AppColor.primary,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                } else if (state is TracosDoencasLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 27,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Doenças',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            textAlign: TextAlign.center,
                            'O risco será aumentado para o desenvolvimento de doença na presença de duas variantes. Quando apenas uma variante é detectada, não há risco aumentado para desenvolver a doença.',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            textAlign: TextAlign.center,
                            'Veja abaixo os riscos genéticos encontrados:',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: Colors.white30),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Raio de borda desejado
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoencasUmaVariante(
                                      id: doenca_uma_variante,
                                      title:
                                          'Doenças com uma variante detectada',
                                      box: widget.box,
                                      especie: widget.ativacao.especie,
                                    ),
                                  ));
                            },
                            child: const Text('Uma variante detectada', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: Colors.white30),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Raio de borda desejado
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoencasUmaVariante(
                                      id: doenca_duas_variante,
                                      title:
                                          'Doenças com duas varianes detectadas',
                                      box: widget.box,
                                      especie: widget.ativacao.especie,
                                    ),
                                  ));
                            },
                            child: const Text('Duas variantes detectadas', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: Colors.white30),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Raio de borda desejado
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoencasUmaVariante(
                                      id: principais,
                                      title:
                                          'Principais doenças genéticas de raça',
                                      box: widget.box,
                                      especie: widget.ativacao.especie,
                                    ),
                                  ));
                            },
                            child: const Text(
                                'Principais doenças genéticas de raça', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.secondary,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 2, color: Colors.white30),
                                borderRadius: BorderRadius.circular(
                                    10.0), // Raio de borda desejado
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isCertificado = true;
                              });
                              reportViewCertificado(
                                name: widget.name,
                                context,
                                ativacao: widget.ativacao,
                                stopLoading: stopLoading,
                                principais: principais,
                                
                              );
                            },
                            child:
                              isCertificado ? LoadingAnimationWidget.horizontalRotatingDots(
          color: Colors.white, size: 30) :  const Text('Certificado de análise genética', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Traços',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: 350,
                          child: Text(
                            textAlign: TextAlign.center,
                            'O DNA contém informações genéticas que influenciam uma variedade de características físicas, tipo e coloração dos pelos. A análise do DNA permite identificar e estudar esses traços genéticos, fornecendo insights sobre a hereditariedade e a diversidade genética. Além de você entender mais sobre essas características, essas informações são especialmente útil em contextos de reprodução seletiva.',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tracos(
                                  especie: widget.ativacao.especie,
                                  id: 'Cor da camada da base dos pelos',
                                  box: widget.box,
                                  subTitle:
                                      'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem. \n Os genes da cor da pelagem básica estão ligados ao fato de o seu cão ter algum pelo escuro e, se tiver, se o pelo escuro é preto, marrom, cinza ou marrom claro.',
                                ),
                              )),
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Cor da camada da base dos pelos',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Tracos(
                                          especie: widget.ativacao.especie,
                                          id: 'Cor da camada da base dos pelos',
                                          box: widget.box,
                                          subTitle:
                                              'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem. \n Os genes da cor da pelagem básica estão ligados ao fato de o seu cão ter algum pelo escuro e, se tiver, se o pelo escuro é preto, marrom, cinza ou marrom claro.',
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
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tracos(
                                  especie: widget.ativacao.especie,
                                  box: widget.box,
                                  id: 'Modificadores da coloração',
                                  subTitle:
                                      'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem. \n Os genes modificadores da cor da pelagem que testamos explicam os padrões de pelagem na maioria dos cães. Ainda não podemos testar alguns padrões de cores, por exemplo, alguns tipos de manchas.',
                                ),
                              )),
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Modificadores da coloração',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Tracos(
                                          especie: widget.ativacao.especie,
                                          box: widget.box,
                                          id: 'Modificadores da coloração',
                                          subTitle:
                                              'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem. \n Os genes modificadores da cor da pelagem que testamos explicam os padrões de pelagem na maioria dos cães. Ainda não podemos testar alguns padrões de cores, por exemplo, alguns tipos de manchas.',
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
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tracos(
                                    especie: widget.ativacao.especie,
                                    box: widget.box,
                                    id: 'Características da pelagem',
                                    subTitle:
                                        'Diversos genes estão ativamente envolvidos e afetam a característica da pelagem, e interagem entre si de maneira complexa. A combinação desses genes é responsável por explicar as características da pelagem nas raças dos cães e gatos.'),
                              )),
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Características da pelagem',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Tracos(
                                            especie: widget.ativacao.especie,
                                            box: widget.box,
                                            id: 'Características da pelagem',
                                            subTitle:
                                                'Diversos genes estão ativamente envolvidos e afetam a característica da pelagem, e interagem entre si de maneira complexa. A combinação desses genes é responsável por explicar as características da pelagem nas raças dos cães e gatos.'),
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
                        InkWell(
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Tracos(
                                    especie: widget.ativacao.especie,
                                    box: widget.box,
                                    id: 'Características físicas',
                                    subTitle:
                                        'Várias características corporais tais como o formato da cabeça e da cauda são influenciados por genes. Um número maior de genes relacionados a características corporais estão sendo constantemente estudados.'),
                              )),
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Características físicas',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Tracos(
                                            especie: widget.ativacao.especie,
                                            box: widget.box,
                                            id: 'Características físicas',
                                            subTitle:
                                                'Várias características corporais tais como o formato da cabeça e da cauda são influenciados por genes. Um número maior de genes relacionados a características corporais estão sendo constantemente estudados.'),
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
                        const SizedBox(
                          height: 50,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            textAlign: TextAlign.start,
                            'Perfil de DNA' , style: TextStyle(
                              
                              color: AppColor.primary,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                        ),
                            const SizedBox( height: 10,),
                            Text(
                            textAlign: TextAlign.center,
                              'O Perfil de DNA é um mapa que mostra a identificação genética de um cão ou gato.' , style: TextStyle( color: AppColor.primary, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox( height: 20,),
                        InkWell(
                          onTap: (){
                            reportViewDNA( context,ativacao: widget.ativacao);
                          },
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Perfil DNA',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  reportViewDNA( context,ativacao: widget.ativacao);
                                },
                                child: const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ParentescoScreen(),));
                          },
                          child: Card(
                            color: const Color(0xffEBEBEB),
                            elevation: 5,
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_circle,
                                color: AppColor.primary,
                              ),
                              title: const Text(
                                'Parentesco',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              trailing: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ParentescoScreen(),));
                                },
                                child: const Icon(
                                  Icons.arrow_forward_ios_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
