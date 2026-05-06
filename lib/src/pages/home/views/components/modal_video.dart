import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ModalVideo extends StatefulWidget {
  final YoutubePlayerController controller;
  const ModalVideo({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<ModalVideo> createState() => _ModalVideoState();
}

class _ModalVideoState extends State<ModalVideo> {
  final box = GetStorage();
  bool modalVideo = false;
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
 
    title: Text('Vídeo de Apresentação do aplicativo'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 300,
          child: Center(
            child: YoutubePlayer(
          controller: widget.controller,
          showVideoProgressIndicator: true,
          onReady: () {
            widget.controller.play();
          },
        )
          
          ),
        ),
        const SizedBox(height: 10,),

        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Fechar', ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                _launchURL('https://www.youtube.com/watch?v=O6Xmd1fxfCM');
                },
                child: Text('Abrir no Youtube' ,),
              ),
            )
          ],
        ),
        const SizedBox(height: 10,),
        CheckboxListTile(value: modalVideo, onChanged: (value) {
            print(modalVideo);
          setState(() {
            modalVideo = value!;
             box.write('modalVideo',  value);
          });
        }, title: Text('Não mostrar novamente',),
                  )
      ],
    ),
  );
  }
}