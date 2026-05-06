
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:Box4Pets/src/pages/profile_dog/views/profile_dog.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/teste_raca.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/tracos_doencas.dart';
import 'package:popover/popover.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ContainerPetsComponents extends StatefulWidget {
  final AppAtivacaoModel appAtivacao;
   final Function(String id, String name) downloadPDF;
  const ContainerPetsComponents({
    Key? key,
    required this.appAtivacao,
    required this.downloadPDF,
  }) : super(key: key);

  @override
  State<ContainerPetsComponents> createState() => _ContainerPetsComponentsState();
}

class _ContainerPetsComponentsState extends State<ContainerPetsComponents> {

  bool extendButton = false;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
                                children: [
                                  
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            border: Border.all(
                                                width: 2,
                                                color: Colors.white30)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 20),
                                          child: Row(
                                            children: [
                                              InkWell(
                                                onTap: (){
                                                   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileDog(
                                            dog: widget.appAtivacao,
                                            testeRaca: widget.appAtivacao
                                                .resultadoRaca,
                                            testeTracosDoencas: widget
                                                .appAtivacao.resultado),
                                      ));
                                                },
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  child: widget
                                                              .appAtivacao
                                                              .url ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/cachorro1_solto 1.png',
                                                          fit: BoxFit.fill,
                                                          height:
                                                              double.infinity,
                                                        )
                                                      : Image.network(widget
                                                          .appAtivacao
                                                          .url!),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Text(
                                                  widget.appAtivacao
                                                      .name,
                                                  style: TextStyle(
                                                      color: AppColor.primary,
                                                      fontSize: 21,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              
                                              
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                   Positioned(
                                    top: 30,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 20),
                                      child: widget.appAtivacao.resultadoRaca || widget.appAtivacao.ourosTestes || widget.appAtivacao.resultado ? InkWell(
                                        child: Icon(
                                          Icons.more_vert_sharp,
                                          color: Color(0xff5a1d81),
                                          size: 30,
                                        ),
                                        onTap: () => showPopover(
                                          context: context,
                                          direction: PopoverDirection.bottom,
                                          width: 250,
                                          height: 150,
                                          backgroundColor: Colors.deepPurple.shade400,
                                           bodyBuilder: (context) => Column(
                                            children: [
                                              widget.appAtivacao.resultado ? Container(
                                                height: 50,
                                                width: double.infinity,
                                                color: Colors.deepPurple[400],
                                                child: TextButton(onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TracosDoencas(
                                                        box: widget
                                                            .appAtivacao
                                                            .Case_ID,
                                                        name: widget
                                                            .appAtivacao
                                                            .name,
                                                            ativacao: widget
                                                            .appAtivacao,
                                                            url: widget.appAtivacao.url,
                                                      )
                                                    ));

                                                }, child: Text('Traços e Doenças', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),),
                                              ) : Container(),
                                             
                                              widget.appAtivacao.resultadoRaca ? Container(
                                                height: 50,
                                                width: double.infinity,
                                                color: Colors.deepPurple[300],
                                                child: TextButton(onPressed: () {
                                                  Navigator.pop(context);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TesteRaca(
                                                        id: widget
                                                            .appAtivacao
                                                            .Case_ID,
                                                        name: widget
                                                            .appAtivacao
                                                            .name,
                                                            ativacao: widget
                                                            .appAtivacao,
                                                      )
                                                    ));
                                                }, child: Text('Raças', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),),
                                              ) : Container(),
                                              widget.appAtivacao.ourosTestes ? Container(
                                                height: 50,
                                                width: double.infinity,
                                                color: Colors.deepPurple[200],
                                                child: TextButton(onPressed: () async{
                                                  Navigator.pop(context);
                                                  if (Platform.isAndroid) {
                                                    widget.downloadPDF( widget.appAtivacao.Case_ID, widget.appAtivacao.name);
                                                        if (await Permission.storage.request().isGranted) {
                                                            widget.downloadPDF( widget.appAtivacao.Case_ID, widget.appAtivacao.name);
                                                        }else{
                                                          await Permission.storage.request();
                                                        }
                                                      }else{
                                                        widget.downloadPDF( widget.appAtivacao.Case_ID, widget.appAtivacao.name);
                                                      }
                                                }, child: Text('Outros exames', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),),
                                              ) : Container(),
                                            ],
                                           ),),
                                      ): Container(), 
                                    ) 
                                  )
                                ],
                              );
  }
}