// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/models/app_lista_doencas_model.dart';

class DoencaCompletaComponent extends StatelessWidget {
  final AppListaDoencasModel doenca;
  final String resultado;

  const DoencaCompletaComponent({
    Key? key,
    required this.doenca,
    required this.resultado,
  }) : super(key: key);

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
                    doenca.doenca,
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
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                          '${doenca.doenca} (${doenca.gene})',
                          style:  TextStyle(
                              color: AppColor.primary,
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
                            style:  TextStyle(
                                color: AppColor.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        const Text(
                          'Gene',
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
                            doenca.gene,
                            style: const TextStyle(
                                color: Color(0xff600499),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        const Text(
                          'Variante',
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
                            doenca.variante,
                            style: const TextStyle(
                                color: Color(0xff600499),
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 55,
              ),
              const Text(
                'Sobre a doença',
                style: TextStyle(
                    color: Color(0xff600499),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                doenca.sobre_doenca,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              doenca.manifesta.isNotEmpty ? Text(
                'Quando Manifesta',
                style: TextStyle(
                    color: Color(0xff600499),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ) : Container(),
              const SizedBox(
                height: 10,
              ),
              Text(
                doenca.manifesta,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Recomendações',
                style: TextStyle(
                    color: Color(0xff600499),
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                doenca.recomendacoes,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              doenca.racas.isNotEmpty
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
              Text(
                doenca.racas,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              doenca.referencias.isNotEmpty
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
              Text(
                doenca.referencias,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
