// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Box4Pets/src/pages/destaques/views/components/screen_expanded.dart';
import 'package:flutter/material.dart';

import '../../models/blog_model.dart';

class PrimeiroDestaque extends StatelessWidget {
  final BlogModel listDestaques;

  const PrimeiroDestaque({
    Key? key,
    required this.listDestaques,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ScreenExpanded(blog: listDestaques, tag: 'first tag'),
            ));
      },
      child: SizedBox(
        height: 218,
        width: double.infinity,
        child: Stack(
          children: [
            Hero(
              tag: 'first tag',
              child: Container(
                width: 353,
                height: 218,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                      image: NetworkImage(listDestaques.banner[0].url),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 340,
                    child: Text(
                      listDestaques.titulo,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  SizedBox(
                    width: 300,
                    child: Text(
                      listDestaques.subTitulo,
                      maxLines: 2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
