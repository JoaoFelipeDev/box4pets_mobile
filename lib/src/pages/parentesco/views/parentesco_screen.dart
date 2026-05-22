import 'dart:convert';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/parentesco/bloc/parentesco_bloc.dart';
import 'package:Box4Pets/src/pages/parentesco/models/ativacao_parentesco_model.dart';
import 'package:Box4Pets/src/pages/parentesco/models/parentesco_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

class ParentescoScreen extends StatefulWidget {
  const ParentescoScreen({Key? key}) : super(key: key);

  @override
  _ParentescoScreenState createState() => _ParentescoScreenState();
}

class _ParentescoScreenState extends State<ParentescoScreen> {
  bool supostaMaeChecked = false;
  final box = GetStorage();
  late final ParentescoBloc _parentescoBloc;
  late UserActivationModel user;
  List<AtivacaoParentescoModel> list = [];
  String ativacaoValuePai = '';
  String ativacaoValueMae = '';
  String ativacaoValueFilho = '';
  String idPai = '';
  String? idMae;
  String idFilho = '';
  TextEditingController emailController = TextEditingController();

    @override
  void initState() {
    String json = box.read('user');
    user = UserActivationModel.fromJson(jsonDecode(json));
    _parentescoBloc = ParentescoBloc();
    _parentescoBloc.add(GetAtivacoes(user.email));
    super.initState();
  }


  @override
  void dispose() {
    _parentescoBloc.close();
    super.dispose();
  }

  validate(){
    String email =  emailController.text;
    if(email.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preencha o campo de e-mail')));
      return;
    }else if(idPai == idMae){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Escolha ativacoes diferentes')));
      return;
  }else{
     _parentescoBloc.add(CreateParentesco(ParentescoModel(email: email, info_suposto_pai: [idPai],info_suposto_mae: [idMae ?? ''], numero_de_relatorio: '',info_filho: [idFilho], swab_filho: list.firstWhere((element) => element.id == idFilho).swab, swab_suposto_pai: list.firstWhere((element) => element.id == idPai).swab, )));
  
  }
  }
  

  @override
  Widget build(BuildContext context) {
    setState(() {
      emailController.text = user.email;
    });
    return BlocListener<ParentescoBloc, ParentescoState>(
      bloc: _parentescoBloc,
      listener: (context, state) {
        if(state is ParentescoGetAtivacoesLoaded){
          setState(() {
            list = state.ativacoes;
            ativacaoValuePai = '${state.ativacoes[0].nome} - ${state.ativacoes[0].swab}';
            ativacaoValueMae = '${state.ativacoes[0].nome} - ${state.ativacoes[0].swab}';
            ativacaoValueFilho = '${state.ativacoes[0].nome} - ${state.ativacoes[0].swab}';
            idPai = state.ativacoes[0].id;
            idMae = state.ativacoes[0].id;
            idFilho = state.ativacoes[0].id;
          });

        }else if(state is ParentescoSuccess){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 131,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                      onTap: () => Navigator.popAndPushNamed(context, '/base'),
                      child: Image.asset('assets/images/logo_tracos.png')),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                textAlign: TextAlign.center,
                'Relatório Parentesco', style: TextStyle(
                                color: AppColor.primary,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),),
              const SizedBox(height: 20),
              Text('Filho', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  underline: Container(),
                  onChanged: (String? value) {
                    setState(() {
                      ativacaoValueFilho = value!;
                      idFilho = list.firstWhere((element) => '${element.nome} - ${element.swab}' == value).id;
                    });
                  },
                  value: ativacaoValueFilho,
                  items: list.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: '${value.nome} - ${value.swab}',
                      child: Row(
                        children: [
                          Text(value.nome),
                          const Spacer(),
                          Text(
                            value.swab,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('Suposto Pai', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  underline: Container(),
                  onChanged: (String? value) {
                    setState(() {
                      ativacaoValuePai = value!;
                      idPai = list.firstWhere((element) => '${element.nome} - ${element.swab}' == value).id;
                    });
                  },
                  value: ativacaoValuePai,
                  items: list.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: '${value.nome} - ${value.swab}',
                      child: Row(
                        children: [
                          Text(value.nome),
                          const Spacer(),
                          Text(
                            value.swab,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Checkbox(
                    value: supostaMaeChecked,
                    onChanged: (value) {
                      setState(() {
                        supostaMaeChecked = value!;
                      });
                    },
                  ),
                  Text('Suposta Mãe', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: supostaMaeChecked ? 50 : 0,
                decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton(
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  underline: Container(),
                  onChanged: (String? value) {
                    setState(() {
                      ativacaoValueMae = value!;
                      idMae = list.firstWhere((element) => '${element.nome} - ${element.swab}' == value).id;
                    });
                  },
                  value: ativacaoValueMae,
                  items: list.map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: '${value.nome} - ${value.swab}',
                      child: Row(
                        children: [
                          Text(value.nome),
                          const Spacer(),
                          Text(
                            value.swab,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text('E-mail para receber o resultado', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                    color: const Color(0xffFFFFFF),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                
                ),
                onPressed: () {
                  validate();
                },
                child: Text('Enviar', style: TextStyle(fontSize: 16, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
