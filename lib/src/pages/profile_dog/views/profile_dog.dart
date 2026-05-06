// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/service/util_service.dart';
import 'package:flutter/material.dart';

import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileDog extends StatelessWidget {
  final bool testeRaca;
  final bool testeTracosDoencas;
  final AppAtivacaoModel dog;
  ProfileDog({
    Key? key,
    required this.testeRaca,
    required this.testeTracosDoencas,
    required this.dog,
  }) : super(key: key);
  final _utils = UtilService();
  @override
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    child: dog.url != null
                        ? Image.network(dog.url!)
                        : Image.asset('assets/images/cachorro1_solto 1.png'),
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: AppColor.primary,
                  //       borderRadius: BorderRadius.circular(100),
                  //     ),
                  //     child: IconButton(
                  //       onPressed: () {},
                  //       icon: const Icon(
                  //         Icons.add,
                  //         color: Colors.white,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Text(
              dog.name,
              style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 14,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                dog.resultadoRaca
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xff00D4C5),
                            borderRadius: BorderRadius.circular(14.28)),
                        child: const Text(
                          'Raças',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : Container(),
                const SizedBox(
                  width: 14,
                ),
                dog.resultadoRaca
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xff00D4C5),
                            borderRadius: BorderRadius.circular(14.28)),
                        child: const Text(
                          'Traços e Doenças',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    : Container(),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Nascimento',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  _utils.formatDateTime(DateTime.parse(dog.nascimento)),
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Espécie',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.especie,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.dog,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Raça',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.raca,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.person,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Tutor',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.nome_cliente,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.marsAndVenus,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Sexo',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.sexo,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.registered,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Registro',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.registro!.isEmpty ? 'Sem registro' : dog.registro!,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
            const SizedBox(
              height: 17,
            ),
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.microchip,
                  color: AppColor.primary,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  'Chip',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  dog.chip!.isEmpty ? 'Sem chip' : dog.chip!,
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
