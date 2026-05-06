// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:Box4Pets/src/pages/destaques/views/components/screen_expanded.dart';

class Cards extends StatelessWidget {
  final BlogModel listTreinamento;
  final int index;
  const Cards({
    Key? key,
    required this.listTreinamento,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenExpanded(
                blog: listTreinamento,
                tag: listTreinamento.id + index.toString()),
          )),
      child: Container(
        height: 115,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: AppColor.primary),
        child: Row(
          children: [
            Hero(
              tag: listTreinamento.id + index.toString(),
              child: Container(
                height: double.infinity,
                width: 127,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(listTreinamento.banner[0].url),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(
              width: 16.47,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                SizedBox(
                  width: 180,
                  child: Text(
                    maxLines: 2,
                    listTreinamento.titulo,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 50,
                  child: Text(
                    maxLines: 3,
                    listTreinamento.subTitulo,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
