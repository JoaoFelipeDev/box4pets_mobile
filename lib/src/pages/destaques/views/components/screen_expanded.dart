// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';

class ScreenExpanded extends StatelessWidget {
  final BlogModel blog;
  final String tag;
  const ScreenExpanded({
    Key? key,
    required this.blog,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      Hero(
                        tag: tag,
                        child: Image.network(
                          blog.banner[0].url,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            blog.titulo,
                            maxLines: 2,
                            style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Text(
                            blog.conteudo,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
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
