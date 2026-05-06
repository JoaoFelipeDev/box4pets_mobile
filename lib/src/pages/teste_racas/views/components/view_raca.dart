// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:Box4Pets/config/app_color.dart';

import '../../models/racas_model.dart';

class ViewRaca extends StatelessWidget {
  RacasModel racaModel;
  ViewRaca({
    Key? key,
    required this.racaModel,
  }) : super(key: key);

  openModal(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          racaModel.voce_sabia,
                          style: const TextStyle(
                            height: 1.7,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 350,
                    child: Hero(
                      tag: racaModel.url ??
                          'assets/images/cachorro1_solto 1.png',
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: racaModel.url != null
                                ? NetworkImage(racaModel.url!) as ImageProvider
                                : const AssetImage(
                                    'assets/images/cachorro1_solto 1.png',
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 25),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            border: Border.all(
                              width: 2,
                              color: Colors.white30,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                child: Text(
                                  racaModel.raca,
                                  style: TextStyle(
                                      color: AppColor.primary,
                                      fontSize: 27.31,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(
                                height: 50,
                              ),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.ruler,
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Altura',
                                        style: TextStyle(
                                            fontSize: 15.87,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary),
                                      ),
                                      Text(
                                        racaModel.altura,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.weightHanging,
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Peso',
                                        style: TextStyle(
                                            fontSize: 15.87,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary),
                                      ),
                                      Text(
                                        racaModel.peso,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.dog,
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Expectativa de vida',
                                        style: TextStyle(
                                            fontSize: 15.87,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary),
                                      ),
                                      Text(
                                        racaModel.expectativa_de_vida,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.ruler,
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Popularidade',
                                        style: TextStyle(
                                            fontSize: 15.87,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          racaModel.popularidade,
                                          style: const TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.earthAmericas,
                                    color: AppColor.primary,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Região de Origem',
                                        style: TextStyle(
                                            fontSize: 15.87,
                                            fontWeight: FontWeight.bold,
                                            color: AppColor.primary),
                                      ),
                                      Text(
                                        racaModel.regiao_origem,
                                        style: const TextStyle(
                                          fontSize: 11,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  racaModel.origem_raca != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset(
                              'assets/images/origem_raca.png',
                              width: 150,
                              height: 200,
                            ),
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Origem da Raça',
                                style: TextStyle(
                                    color: Color(0xff600499),
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  Text(
                    racaModel.origem_raca ?? '',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        width: 200,
                        child: Text(
                          'Principais Características',
                          style: TextStyle(
                              color: Color(0xff600499),
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Image.asset(
                        'assets/images/principais_caracteristicas.png',
                        width: 150,
                        height: 200,
                      ),
                    ],
                  ),
                racaModel.principais_caracteristicas.isNotEmpty ?  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        racaModel.principais_caracteristicas ?? '',
                        style: const TextStyle(
                          height: 1.7,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ): Container(),
                  const SizedBox(
                    height: 30,
                  ),
                  racaModel.descricao_raca != null
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          color: AppColor.primary,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/descricao_raca.png',
                                    width: 150,
                                    height: 200,
                                  ),
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      textAlign: TextAlign.end,
                                      'Descrição da Raça',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    racaModel.descricao_raca ?? '',
                                    style: const TextStyle(
                                      height: 1.7,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                 racaModel.pelagem.isNotEmpty ? Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColor.orange,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                textAlign: TextAlign.end,
                                'Pelagem',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Image.asset(
                              'assets/images/pelagem.png',
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                       racaModel.pelagem.isNotEmpty ? Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              racaModel.pelagem ?? '',
                              style: const TextStyle(
                                height: 1.7,
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ): Container(),
                        const SizedBox(
                          height: 30,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 5,
                                backgroundColor: AppColor.primary),
                            onPressed: () {
                              openModal(context);
                            },
                            child: const Text(
                              'Você sabia?',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  ) : Container(),
                 racaModel.cuidados_gerais.isNotEmpty ? Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: Text(
                          textAlign: TextAlign.end,
                          'Cuidados Gerais',
                          style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Image.asset(
                        'assets/images/cuidados_gerais.png',
                        fit: BoxFit.cover,
                        width: 150,
                        height: 250,
                      ),
                    ],
                  ): Container(),
                 racaModel.cuidados_gerais.isNotEmpty ? Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        racaModel.cuidados_gerais ?? '',
                        style: const TextStyle(
                          height: 1.7,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ): Container(),
                ],
              ),
            ),
            Positioned(
                top: 16,
                right: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: AppColor.primary),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColor.secondary,
                      size: 24,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
