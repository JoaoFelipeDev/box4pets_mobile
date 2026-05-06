import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/destaques/bloc/blog_bloc.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/cards.dart';
import 'components/primeiro_destaque.dart';
import 'components/segundo_destaque.dart';
import 'components/terceiro_destaque.dart';
import 'components/view_more.dart';

class Destaques extends StatefulWidget {
  const Destaques({Key? key}) : super(key: key);

  @override
  _DestaquesState createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques> {
  late final BlogBloc _blogBloc;
  List<BlogModel> listDestaques = [];
  List<BlogModel> listNovidades = [];
  List<BlogModel> listTreinamento = [];
  @override
  void initState() {
    _blogBloc = BlogBloc();
    _blogBloc.add(BlogGetEvent());
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      body: BlocBuilder<BlogBloc, BlogState>(
        bloc: _blogBloc,
        builder: (context, state) {
          if (state is BlogLoaded) {
            listDestaques = state.listBlog
                .where(
                  (element) => element.destaques,
                )
                .toList();
            listNovidades = state.listBlog
                .where(
                  (element) => element.novidades,
                )
                .toList();
            listTreinamento = state.listBlog
                .where(
                  (element) => element.treinamentos,
                )
                .toList();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      PrimeiroDestaque(listDestaques: listDestaques[0]),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SegundoDestaque(
                            listDestaques: listDestaques[1],
                          ),
                          TerceiroDestaque(
                            listDestaques: listDestaques[2],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Conheça as Raças',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewMore(
                                          listBlog: listNovidades,
                                          title: 'Conheça as Raças'),
                                    ));
                              },
                              child: Text('Ver mais'))
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Cards(
                                index: index,
                                listTreinamento: listNovidades[index],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  height: 18,
                                ),
                            itemCount: 2),
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Conheça Traços e Doenças',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewMore(
                                          listBlog: listTreinamento,
                                          title: 'Conheça Traços e Doenças'),
                                    ));
                              },
                              child: Text('Ver mais'))
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      SizedBox(
                        height: 250,
                        child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Cards(
                                index: index,
                                listTreinamento: listTreinamento[index],
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  height: 18,
                                ),
                            itemCount: 2),
                      ),
                      const SizedBox(
                        height: 100,
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (state is BlogLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
