// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/tracos/models/tracos_model.dart';

class TracosResumoComponent extends StatelessWidget {
  final TracosModel tracos;
  final String id;
  final String resultado;

  const TracosResumoComponent({
    Key? key,
    required this.tracos,
    required this.id,
    required this.resultado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              Text(
                textAlign: TextAlign.center,
                id,
                style: const TextStyle(
                    color: Color(0xff600499),
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 25,
              ),
              Center(
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23)),
                  child: Padding(
                    padding: const EdgeInsets.all(21),
                    child: Column(
                      children: [
                        Text(
                          tracos.traco,
                          style: const TextStyle(
                              color: Color(0xff600499),
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 29,
                        ),
                        const Text(
                          'Resultado',
                          style: TextStyle(
                              color: Color(0xff600499),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(215, 255, 252, 1),
                                Color.fromRGBO(0, 212, 197, 1),
                              ],
                            ),
                          ),
                          child: Text(
                            textAlign: TextAlign.center,
                            resultado,
                            style: const TextStyle(
                                color: Color(0xff600499),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        tracos.gene1 != null
                            ? const Text(
                                'Gene',
                                style: TextStyle(
                                    color: Color(0xff600499),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            : Container(),
                        tracos.gene1 != null
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(215, 255, 252, 1),
                                      Color.fromRGBO(0, 212, 197, 1),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  tracos.gene1,
                                  style: const TextStyle(
                                      color: Color(0xff600499),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),
                        tracos.variante != null
                            ? const Text(
                                'Variante',
                                style: TextStyle(
                                    color: Color(0xff600499),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            : Container(),
                        tracos.variante != null
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 30),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(215, 255, 252, 1),
                                      Color.fromRGBO(0, 212, 197, 1),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  textAlign: TextAlign.center,
                                  tracos.variante ?? '',
                                  style: const TextStyle(
                                      color: Color(0xff600499),
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 55,
              ),
              tracos.sobre_traco != null
                  ? const Text(
                      'Sobre o Traço',
                      style: TextStyle(
                          color: Color(0xff600499),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    )
                  : Container(),
              tracos.sobre_traco != null
                  ? const SizedBox(
                      height: 10,
                    )
                  : Container(),
              tracos.sobre_traco != null
                  ? Text(
                      tracos.sobre_traco ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              tracos.racas != null
                  ? const Text(
                      'Raças',
                      style: TextStyle(
                          color: Color(0xff600499),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              tracos.racas != null
                  ? Text(
                      tracos.racas ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              tracos.referencias != null
                  ? const Text(
                      'Referências',
                      style: TextStyle(
                          color: Color(0xff600499),
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              tracos.referencias != null
                  ? Text(
                      tracos.referencias ?? '',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
