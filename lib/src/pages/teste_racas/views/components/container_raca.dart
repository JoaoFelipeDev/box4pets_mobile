// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Box4Pets/config/app_color.dart';
import 'package:flutter/material.dart';

import 'package:Box4Pets/src/pages/teste_racas/views/components/view_raca.dart';

import '../../models/racas_model.dart';

class ContainerRaca extends StatelessWidget {
  String porcent;
  String raca;
  String? url;
  RacasModel racaModel;

  ContainerRaca({
    Key? key,
    required this.porcent,
    required this.raca,
    this.url,
    required this.racaModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewRaca(racaModel: racaModel),
          )),
      child: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: url ?? 'assets/images/cachorro1_solto 1.png',
                child: Container(
                  width: 175,
                  height: 151.89,
                  color: Colors.white,
                  // decoration: BoxDecoration(
                  //   image: DecorationImage(
                  //       image: url != null
                  //           ? NetworkImage(url!) as ImageProvider
                  //           : const AssetImage(
                  //               'assets/images/cachorro1_solto 1.png'),
                  //       fit: BoxFit.cover),
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  child: url != null ? Image.network(url!) : Image.asset(
                    'assets/images/cachorro1_solto 1.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    '${double.parse(porcent).ceilToDouble()}%',
                    style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 40.75,
                        fontWeight: FontWeight.bold),
                  ))
            ],
          ),
          Text(
            raca,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
