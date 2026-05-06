// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:screenshot/screenshot.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/src/pages/teste_racas/bloc/teste_racas_bloc.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/components/container_raca.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/components/gerar_pdf_racas.dart';

import '../models/app_resultado_raca_model.dart';
import '../models/racas_model.dart';

class TesteRaca extends StatefulWidget {
  final String id;
  final String name;
  final AppAtivacaoModel ativacao;
  const TesteRaca({
    Key? key,
    required this.id,
    required this.name,
    required this.ativacao,
  }) : super(key: key);

  @override
  _TesteRacaState createState() => _TesteRacaState();
}

class _TesteRacaState extends State<TesteRaca> {
  Uint8List? _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  late final TesteRacasBloc _testeRacasBloc;
  Map<String, double> dataMap = {};
  List<Color> colorList = [
    const Color(0xff29ccb5),
    const Color(0xff6666ac),
    const Color(0xff544494),
    const Color.fromARGB(255, 164, 198, 237),
    const Color.fromARGB(255, 68, 105, 148),
    const Color(0xff6A5ACD),
    const Color(0xff483D8B),
    const Color(0xff191970),
    const Color(0xff000080),
    const Color(0xff00008B),
    const Color(0xff0000CD),
    const Color(0xff0000FF),
    const Color(0xff7B68EE),
    const Color(0xff9370DB),
    const Color(0xff8A2BE2),
    const Color(0xff4B0082),
  ];

  List<Widget> listText = [
    Text(
      'Desenvolvido com uma tecnologia muito avançada, este teste genético oferece uma visão fascinante da árvore genealógica do seu cão, revelando as raças que contribuíram para sua composição genética.',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    ),
    Text(
      'Entenda melhor o resultado:',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
    Text(
      'Raças Ascendentes: Para adicionar uma camada extra de profundidade à sua análise, o teste de DNA da Box4Pets também identifica quaisquer raças que tenham sido parte da composição racial dos ancestrais do seu cão por mais de três gerações',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    ),
    Text(
      'Como são raças formadoras dos ancestrais, as raças ascendentes têm mínima influência na definição de características físicas e tendências de comportamento. Dessa forma, os cães de raça pura também podem apresentar em sua composição raças ascendentes.',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    ),
    Text(
      'Raças Indeterminadas: O sequenciamento genético de cães no Brasil é uma área em desenvolvimento, e é natural encontrar resultados com "Raças Indeterminadas". Isso ocorre devido à diversidade única das misturas genéticas em alguns cães, que podem não corresponder diretamente às raças tradicionais em nosso banco de dados. Além disso, a mestiçagem histórica e a presença de raças menos conhecidas também contribuem para essa categoria. Essa situação não representa uma limitação do teste de DNA, mas reflete a riqueza da diversidade canina brasileira, enquanto a pesquisa e tecnologia continuam avançando para aprimorar nosso entendimento da genética canina.',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    ),
  ];
  openModal() {
    CarouselSliderController buttonCarouselController = CarouselSliderController();
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close))
                  ],
                ),
                CarouselSlider.builder(

                                carouselController: buttonCarouselController,
                                options: CarouselOptions(
                                  height: 400,
                // Fullscreen height
                viewportFraction: 1.0,
                // Take up the whole screen width
                enlargeCenterPage: false,
                enableInfiniteScroll: false,
                                ),
                                itemCount: listText.length,

                                itemBuilder:
                  (BuildContext context, int itemIndex, int pageViewIndex) =>
                      Container(
                child: Center(child: listText[itemIndex]),
                                ),
                              ),
                            
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {
                          buttonCarouselController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        },
                        child: Text('Voltar')),
                    TextButton(
                        onPressed: () {
                          buttonCarouselController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.linear);
                        },
                        child: Text('Póximo')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    _testeRacasBloc = TesteRacasBloc();
    _testeRacasBloc.add(TesteRacasGetAppResultadoRacasEvent(id: widget.id));
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 70, bottom: 18, left: 41),
              height: 131,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xff28D7CC),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColor.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 70,
                  ),
                  Image.asset('assets/images/logoB4p.png')
                ],
              ),
            ),
            const SizedBox(
              height: 27,
            ),
            BlocBuilder<TesteRacasBloc, TesteRacasState>(
              bloc: _testeRacasBloc,
              builder: (context, state) {
                if (state is TesteRacasLoaded) {
                  List<AppResultadoRacaModel> list = state.resuldado;
                  List<RacasModel> listRacas = [];

                  for (var porcent in list) {
                    for (var racas in state.racas) {
                      if (porcent.racas == racas.raca) {
                        listRacas.add(RacasModel(
                            id: racas.id,
                            raca: racas.raca,
                            regiao_origem: racas.regiao_origem,
                            origem_raca: racas.origem_raca,
                            peso: racas.peso,
                            altura: racas.altura,
                            expectativa_de_vida: racas.expectativa_de_vida,
                            pelagem: racas.pelagem,
                            principais_caracteristicas:
                                racas.principais_caracteristicas,
                            cuidados_gerais: racas.cuidados_gerais,
                            voce_sabia: racas.voce_sabia,
                            popularidade: racas.popularidade,
                            health: racas.health,
                            porcent: porcent.porcent,
                            descricao_raca: racas.descricao_raca,
                            url: racas.url));
                      }
                    }
                  }

                  listRacas.sort(
                    (a, b) => b.porcent!.compareTo(a.porcent!),
                  );

                  list.sort(
                    (a, b) => b.porcent.compareTo(a.porcent),
                  );
                  for (var element in list) {
                    dataMap.addAll({
                      '${element.racas.length <= 35 ? element.racas : element.racas.substring(0, 35) + '\n'   } - ${double.parse((element.porcent * 100).toString()).roundToDouble()}%':
                          element.porcent * 100
                    });
                  
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              border:
                                  Border.all(width: 2, color: Colors.white30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        child: Image.asset(
                                          'assets/images/cachorro1_solto 1.png',
                                          fit: BoxFit.fill,
                                          height: double.infinity,
                                        ),
                                      ),
                                      Text(
                                        widget.name,
                                        style: TextStyle(
                                            color: AppColor.primary,
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold),
                                      ),
                                       InkWell(
                                          onTap: () async {
                                           await screenshotController
                                        .capture(delay: const Duration(milliseconds: 10))
                                        .then((Uint8List? image) {
                                      setState(() {
                                        _imageFile = image;
                                      });
                                    }).catchError((onError) {
                                     
                                    });
                                  
                                    reportViwRacas(context,image: _imageFile!, ativacao: widget.ativacao);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 22),
                                            height: 100,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: const Color.fromRGBO(
                                                    0, 212, 197, 0.83)),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                               
                                                     Icon(
                                                        Icons
                                                            .ios_share_outlined,
                                                        color: Colors.white,
                                                        size: 30,
                                                      ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Compartilhar',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 50),
                                    child: Screenshot(
                                      controller: screenshotController,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: PieChart(
                                            dataMap: dataMap,
                                            colorList: colorList,
                                            chartType: ChartType.disc,
                                            totalValue: 100,
                                            initialAngleInDegree: 0,
                                            chartRadius:
                                                MediaQuery.of(context).size.width / 2,
                                            chartValuesOptions:
                                                const ChartValuesOptions(
                                                    decimalPlaces: 0,
                                                    showChartValues: true,
                                                    showChartValuesOutside: true,
                                                    showChartValuesInPercentage: true,
                                                    showChartValueBackground: false),
                                            legendOptions: const LegendOptions(
                                              showLegends: true,
                                              legendPosition: LegendPosition.bottom,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  
                                  
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => ContainerRaca(
                                    porcent: (listRacas[index].porcent! * 100)
                                        .toString(),
                                    raca: listRacas[index].raca,
                                    url: listRacas[index].url,
                                    racaModel: listRacas[index],
                                  ),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                    width: 15,
                                  ),
                              itemCount: state.resuldado.length),
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff00D4C5)),
                            onPressed: () {
                              openModal();
                            },
                            child: Text(
                              'Vamos entender os resultados?',
                              style: TextStyle(
                                  fontSize: 18.65,
                                  color: Color(0xff600499),
                                  fontWeight: FontWeight.bold),
                            )),
                        const SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  );
                } else if (state is TesteRacasLoading) {
                  return const Center(
                    child: Box4PetsLoader(),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
