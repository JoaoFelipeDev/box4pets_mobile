// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Box4Pets/src/pages/destaques/views/components/screen_expanded.dart';
import 'package:flutter/material.dart';

import '../../models/blog_model.dart';

class TerceiroDestaque extends StatelessWidget {
  final BlogModel listDestaques;
  const TerceiroDestaque({
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
                ScreenExpanded(blog: listDestaques, tag: 'terceiro destaque'),
          ),
        );
      },
      child: SizedBox(
        height: 244,
        width: 163,
        child: Stack(
          children: [
            Hero(
              tag: 'terceiro destaque',
              child: Container(
                width: double.infinity,
                height: double.infinity,
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
                    width: 150,
                    child: Text(
                      textAlign: TextAlign.start,
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
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
