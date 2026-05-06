// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:Box4Pets/src/pages/destaques/views/components/cards.dart';

import '../../../../../config/app_color.dart';

class ViewMore extends StatelessWidget {
  final List<BlogModel> listBlog;
  final String title;
  ViewMore({
    Key? key,
    required this.listBlog,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    title,
                    style: const TextStyle(
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
        padding: const EdgeInsets.only(left: 16, right: 16, top: 30),
        child: ListView.separated(
          itemCount: listBlog.length,
          separatorBuilder: (context, index) => const SizedBox(
            height: 20,
          ),
          itemBuilder: (context, index) =>
              Cards(listTreinamento: listBlog[index], index: index),
        ),
      ),
    );
  }
}
