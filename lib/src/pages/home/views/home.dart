import 'package:Box4Pets/config/app_color.dart';

import 'package:Box4Pets/src/pages/home/bloc/app_ativacao_bloc.dart';
import 'package:Box4Pets/src/pages/home/views/components/container_pets_components.dart';
import 'package:Box4Pets/src/pages/home/views/components/modal_video.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../destaques/views/components/screen_expanded.dart';
import '../repositories/app_ativacao_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool modalVideo = false;
  late YoutubePlayerController _controller;
  int countAtivacao = 0;
  final appAtivacaoRepository = AppAtivacaoRepository();
  final box = GetStorage();
  String function = '';
  bool extendButton = false;
  late final AppAtivacaoBloc _appAtivacaoBloc;
  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: 'O6Xmd1fxfCM', // ID do vídeo do YouTube
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    Future.delayed(Duration.zero, () {
      if (box.read('modalVideo') == null) {
        modalVideoApresentacao();
      }
    });
    _appAtivacaoBloc = AppAtivacaoBloc();
    _appAtivacaoBloc.add(AppAtivacaoGetEvent());
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getVersion();
    });
    super.initState();
  }

  downloadPDF(String id, String name) {
    _appAtivacaoBloc.add(AppAtivacaoSDownloadPDF(id: id, name: name));
  }

  getVersion() async {
    final Response<dynamic> response = await appAtivacaoRepository.getVersion();

    String version = response.data['records'][0]['fields']['Name'];
    if (box.read('version') != version) {
      openModalVersion();
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> getStoragePath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      print('directory android');
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      print('directory IOS');
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Plataforma não suportada");
    }
    return directory!.path;
  }

  Future<void> _launchUrl(String url) async {
    return showDialog(
      context: context,
      builder: (context) {
        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url));
        return Scaffold(
          appBar: AppBar(
              title: Text("Navegação Box4Pets"),
              backgroundColor: AppColor.primary),
          body: WebViewWidget(controller: controller),
        );
      },
    );
  }

  modalVideoApresentacao() {
    return showDialog(
      context: context,
      builder: (context) {
        return ModalVideo(
          controller: _controller,
        );
      },
    );
  }

  modalDownloadPDF(List pdfUrl, List name) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Escolha o PDF que deseja baixar'),
            content: Container(
              height: 200,
              width: 200,
              child: ListView.builder(
                itemCount: pdfUrl.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      name[index],
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _downloadPDF(pdfUrl[index], name[index]);
                    },
                  );
                },
              ),
            ),
          );
        });
  }

  Future<void> _downloadPDF(String pdfUrl, String name) async {
    await Permission.storage.request();
    print('downloadPDF');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Download iniciado'),
      ),
    );

    final savedDir = await getStoragePath();
    print('savedDir');
    final taskId = await FlutterDownloader.enqueue(
      url: pdfUrl,
      savedDir: savedDir,
      fileName: "$name",
      showNotification: true,
      openFileFromNotification: true,
    );
    print('$savedDir/$name');

    if (taskId != null) {
      print('$savedDir/$name');
      await OpenFile.open('$savedDir/$name');
    }
  }

  openModalVersion() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'Uma atualização recente do Box4Pets está disponível agora!'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Deixar para depois',
                  style: TextStyle(color: AppColor.secondary, fontSize: 18),
                )),
            TextButton(
                onPressed: () {
                  if (Theme.of(context).platform == TargetPlatform.iOS) {
                    _launchURL(
                        'https://apps.apple.com/us/app/box4pets/id6467569454?platform=iphone');
                  } else {
                    _launchURL(
                        'https://play.google.com/store/apps/details?id=br.com.box4pets.box_4_pets&pli=1');
                  }
                },
                child: Text(
                  'Atualizar',
                  style: TextStyle(color: AppColor.primary, fontSize: 18),
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppAtivacaoBloc, AppAtivacaoState>(
      bloc: _appAtivacaoBloc,
      listener: (context, state) {
        if (state is AppAtivacaoLoaded) {
          setState(() {
            countAtivacao = state.appAtivacao.length;
          });
        } else if (state is AppDownloadPDF) {
          modalDownloadPDF(
              state.downloadPDFModel.url, state.downloadPDFModel.name);
          // _downloadPDF(state.downloadPDFModel.url, state.downloadPDFModel.name);
          _appAtivacaoBloc.add(AppAtivacaoGetEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xffF6F6F6),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),

                              blurRadius: 7,
                              offset:
                                  Offset(8, 8), // changes position of shadow
                            ),
                          ],
                        ),
                        child: TextFormField(
                          onChanged: (value) {
                            _appAtivacaoBloc.add(
                                AppAtivacaoGetFilterNameEvent(filter: value));
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            hintText: '',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 21,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: const BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: function == 'Aguardando Swab'
                              ? Color(0xff470D6A)
                              : Color(0xffD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                          side: BorderSide()),
                      onPressed: () {
                        _appAtivacaoBloc.add(AppAtivacaoGetFilterEvent(
                            filter: 'Aguardando Swab'));
                        setState(() {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          if (function == 'Aguardando Swab') {
                            function = '';
                            _appAtivacaoBloc.add(AppAtivacaoGetEvent());
                          } else {
                            function = 'Aguardando Swab';
                          }
                        });
                      },
                      child: Text(
                        'Aguardando',
                        style: TextStyle(
                            color: function == 'Aguardando Swab'
                                ? Colors.white
                                : Color(0xff470D6A),
                            fontSize: 12.5),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: function == 'Em Análise'
                              ? Color(0xff470D6A)
                              : Color(0xffD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                          side: BorderSide()),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _appAtivacaoBloc.add(
                            AppAtivacaoGetFilterEvent(filter: ' Em Análise'));
                        setState(() {
                          if (function == 'Em Análise') {
                            function = '';
                            _appAtivacaoBloc.add(AppAtivacaoGetEvent());
                          } else {
                            function = 'Em Análise';
                          }
                        });
                      },
                      child: Text(
                        'Em Análise',
                        style: TextStyle(
                            color: function == 'Em Análise'
                                ? Colors.white
                                : Color(0xff470D6A),
                            fontSize: 12.5),
                      ),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: function == 'Resultado Liberado'
                              ? Color(0xff470D6A)
                              : Color(0xffD9D9D9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                          side: BorderSide()),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _appAtivacaoBloc.add(AppAtivacaoGetFilterEvent(
                            filter: 'Resultado Liberado'));
                        setState(() {
                          if (function == 'Resultado Liberado') {
                            function = '';
                            _appAtivacaoBloc.add(AppAtivacaoGetEvent());
                          } else {
                            function = 'Resultado Liberado';
                          }
                        });
                      },
                      child: Text(
                        'Resultados',
                        style: TextStyle(
                            color: function == 'Resultado Liberado'
                                ? Colors.white
                                : Color(0xff470D6A),
                            fontSize: 12.5),
                      ),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () =>
                      FocusScope.of(context).requestFocus(new FocusNode()),
                  child: const SizedBox(
                    height: 42,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        FocusScope.of(context).requestFocus(new FocusNode()),
                    child: BlocBuilder<AppAtivacaoBloc, AppAtivacaoState>(
                      bloc: _appAtivacaoBloc,
                      builder: (context, state) {
                        if (state is AppAtivacaoLoaded) {
                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                              height: 15,
                            ),
                            itemCount: state.appAtivacao.length,
                            itemBuilder: (context, index) {
                              return ContainerPetsComponents(
                                appAtivacao: state.appAtivacao[index],
                                downloadPDF: downloadPDF,
                              );
                            },
                          );
                        } else if (state is AppAtivacaoLoading) {
                          return Center(
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                                    color: AppColor.primary, size: 60),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ),
                countAtivacao < 2
                    ? Expanded(
                        child: BlocBuilder<AppAtivacaoBloc, AppAtivacaoState>(
                          bloc: _appAtivacaoBloc,
                          builder: (context, state) {
                            if (state is AppAtivacaoLoaded) {
                              return CarouselSlider.builder(
                                options: CarouselOptions(
                                    autoPlay: true,
                                    aspectRatio: 2.0,
                                    enlargeCenterPage: true),
                                itemCount: state.blog.length,
                                itemBuilder: (BuildContext context,
                                        int itemIndex, int pageViewIndex) =>
                                    InkWell(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScreenExpanded(
                                            blog: state.blog[itemIndex],
                                            tag: state.blog[itemIndex].titulo),
                                      )),
                                  child: Container(
                                    width: 330,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: NetworkImage(state
                                              .blog[itemIndex].banner[0].url),
                                          fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        state.blog[itemIndex].titulo,
                                        style: TextStyle(
                                            color: AppColor.primary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      )
                    : Container(),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 12, size.height / 2);
    path.lineTo(size.width, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
