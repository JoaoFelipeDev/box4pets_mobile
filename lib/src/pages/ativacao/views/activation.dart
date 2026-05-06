import 'dart:convert';

import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/src/pages/ativacao/bloc/activation_bloc.dart';
import 'package:Box4Pets/src/pages/ativacao/models/activation_model.dart';
import 'package:Box4Pets/src/pages/ativacao/models/racas_model.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../config/app_color.dart';

class Activation extends StatefulWidget {
  const Activation({Key? key}) : super(key: key);

  @override
  _ActivationState createState() => _ActivationState();
}

const List<String> species = ["Canina", "Felina"];
const List<String> sexo = ["Macho", "Fêmea"];
const List<String> testes = [
  'Origem: Identificação de Raças - Cães',
  'Saúde - Identificação de Doenças Genéticas',
  'Painel Saúde + Painel Origem',
  'Painel de Raça Específica',
  'Teste Único',
  'Perfil de DNA',
  'Teste Genético ALKC RI (registro inicial): Identificação de Raça - Origem',
  'Teste Genético ALKC: Identificação de Doenças, Traços e Perfil de DNA',
];

class _ActivationState extends State<Activation> {
  final box = GetStorage();
  String valueMedida = 'KG';
  String valueIdade = 'Meses';
  String textDataNascimento = 'Data de nascimento';
  TextEditingController nomePet = TextEditingController();
  TextEditingController controllerIdade = TextEditingController();
  TextEditingController controllerSwab = TextEditingController();
  TextEditingController controllerRegistro = TextEditingController();
  TextEditingController controllerMicrochip = TextEditingController();
  final controllerData = MaskedTextController(mask: '00/00/0000');
  final controllerPeso = MaskedTextController(mask: '000');
  String speciesValue = species.first;
  String testeValue = testes.first;
  String racasValue = '';
  String racasCatValue = '';
  String sexoValue = sexo.first;
  late final ActivationBloc _activationBloc;
  List<RacasModel> racas = [];
  List<RacasModel> racasCat = [];
  DateTime? _dataNascimento;
  String _textDataNascimento = '';
  processoDeAtivacao() {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String registro =
        controllerRegistro.text.isNotEmpty ? controllerRegistro.text : 'Não';
    String chip =
        controllerMicrochip.text.isNotEmpty ? controllerMicrochip.text : 'Não';
    String nome = nomePet.text;
    String idade = controllerIdade.text;
    String peso = controllerPeso.text;
    String dataNascimento = controllerData.text;
    String swab = '${controllerSwab.text}_$nome';

    if (nome.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite o nome do seu pet'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (idade.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite a idade do seu pet'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (peso.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite o peso do seu pet'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (_textDataNascimento.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite a data de nascimento do seu pet'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (swab.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite o swab'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      ActivationModel data = ActivationModel(
        dataNascimento: _textDataNascimento,
        case_ID: swab,
        especie: speciesValue,
        raca: speciesValue == 'Canina' ? racasValue : racasCatValue,
        sexo: sexoValue,
        namePet: nome,
        idade: '$idade - $valueIdade',
        peso: valueMedida == "KG"
            ? peso
            : ((int.parse(peso) / 100) * 100).toString(),
        email: user.email,
        name: user.name,
        perfil: user.perfil,
        phone: user.telefone,
        email_app_usuario: user.id,
        testes: testeValue,
        chip: chip,
        registro: registro,
        swab: controllerSwab.text,
      );

      _activationBloc.add(ActivationUser(activation: data));
    }
  }

  String formatDateTime(DateTime dateTime) {
    initializeDateFormatting();

    DateFormat dateFormat = DateFormat.yMd();

    return dateFormat.format(dateTime);
  }

  String formatDateTimeText(DateTime dateTime) {
    initializeDateFormatting();

    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    return dateFormat.format(dateTime);
  }

  @override
  void initState() {
    _activationBloc = ActivationBloc();
    _activationBloc.add(ActivationGetRacas());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ActivationBloc, ActivationState>(
        bloc: _activationBloc,
        listener: (context, state) {
          if (state is ActivationRacasLoaded) {
            setState(() {
              racasValue = state.racasDog[0].racas;
              racasCatValue = state.racasCat[0].racas;
              racas = state.racasDog;
              racasCat = state.racasCat;
            });
          }
        },
        child: Stack(
          children: [
            BlocBuilder<ActivationBloc, ActivationState>(
              bloc: _activationBloc,
              builder: (context, state) {
                if (state is ActivationLoaded) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ativação concluída ',
                            style: TextStyle(
                              color: AppColor.primary,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            'Dentro de 24 horas úteis você receberá em seu email o código de postagem.',
                            style: TextStyle(color: AppColor.primary),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                                style: TextStyle(color: AppColor.primary),
                                text:
                                    'Se não receber verifique sua caixa de SPAM ou entre em contato conosco: ',
                                children: [
                                  TextSpan(
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    text: 'contato@box4pets.com.br',
                                  ),
                                ]),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary),
                              onPressed: () {
                                Navigator.pushNamed(context, '/base');
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                              label: const Text('Voltar'))
                        ],
                      ),
                    ),
                  );
                } else {
                  return Padding(
                    padding:
                        const EdgeInsets.only(top: 150, left: 15, right: 15),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            'Ativação',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 36),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              controller: nomePet,
                              cursorColor: AppColor.primary.withOpacity(0.75),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0.0),
                                hintText: 'Nome do Pet',
                                labelStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.pets_outlined,
                                  color: AppColor.primary,
                                  size: 26,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200, width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.primary.withOpacity(0.75),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              controller: controllerSwab,
                              cursorColor: AppColor.primary.withOpacity(0.75),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0.0),
                                hintText: 'SWAB',
                                labelStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.api_sharp,
                                  color: AppColor.primary,
                                  size: 26,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200, width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.primary.withOpacity(0.75),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              controller: controllerRegistro,
                              cursorColor: AppColor.primary.withOpacity(0.75),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0.0),
                                hintText: 'Numero de registro (Opcional)',
                                labelStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.app_registration_sharp,
                                  color: AppColor.primary,
                                  size: 26,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200, width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.primary.withOpacity(0.75),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: TextFormField(
                              controller: controllerMicrochip,
                              cursorColor: AppColor.primary.withOpacity(0.75),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(0.0),
                                hintText: 'Numero de Microchip (Opcional)',
                                labelStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintStyle: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 16.0,
                                ),
                                prefixIcon: Icon(
                                  Icons.sim_card_sharp,
                                  color: AppColor.primary,
                                  size: 26,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.shade200, width: 2),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                floatingLabelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColor.primary.withOpacity(0.75),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Espécie',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButton(
                              isExpanded: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              underline: Container(),
                              onChanged: (String? value) {
                                setState(() {
                                  speciesValue = value!;
                                });
                              },
                              value: speciesValue,
                              items: species
                                  .map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Escolha a raça',
                            ),
                          ),
                          speciesValue == "Canina"
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    underline: Container(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        racasValue = value!;
                                      });
                                    },
                                    value: racasValue,
                                    items: racas
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value.racas,
                                        child: Row(
                                          children: [
                                            Text(value.racas),
                                            const Spacer(),
                                            Text(
                                              value.racas
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: DropdownButton(
                                    isExpanded: true,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    underline: Container(),
                                    onChanged: (String? value) {
                                      setState(() {
                                        racasCatValue = value!;
                                      });
                                    },
                                    value: racasCatValue,
                                    items: racasCat
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value.racas,
                                        child: Row(
                                          children: [
                                            Text(value.racas),
                                            const Spacer(),
                                            Text(
                                              value.racas
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Sexo',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButton(
                              isExpanded: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              underline: Container(),
                              onChanged: (String? value) {
                                setState(() {
                                  sexoValue = value!;
                                });
                              },
                              value: sexoValue,
                              items:
                                  sexo.map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Teste Adquirido',
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(10)),
                            child: DropdownButton(
                              isExpanded: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              underline: Container(),
                              onChanged: (String? value) {
                                setState(() {
                                  testeValue = value!;
                                });
                              },
                              value: testeValue,
                              items:
                                  testes.map<DropdownMenuItem<String>>((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  child: Text(textDataNascimento),
                                  onPressed: () {
                                    Future<DateTime?> _dataNascimento =
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1900),
                                                lastDate: DateTime(2100))
                                            .then((res) {
                                      setState(() {
                                        textDataNascimento =
                                            formatDateTimeText(res!);
                                        _textDataNascimento =
                                            formatDateTime(res);
                                      });
                                    });
                                  }),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextFormField(
                                    controller: controllerPeso,
                                    cursorColor:
                                        AppColor.primary.withOpacity(0.75),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(0.0),
                                      hintText: 'Peso',
                                      labelStyle: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintStyle: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 16.0,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.line_weight,
                                        color: AppColor.primary,
                                        size: 26,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.primary
                                                .withOpacity(0.75),
                                            width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'KG',
                                      groupValue: valueMedida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          valueMedida = value!;
                                        });
                                      },
                                    ),
                                    Text('KG')
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'G',
                                      groupValue: valueMedida,
                                      onChanged: (String? value) {
                                        setState(() {
                                          valueMedida = value!;
                                        });
                                      },
                                    ),
                                    Text('G')
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xffFFFFFF),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: controllerIdade,
                                    cursorColor:
                                        AppColor.primary.withOpacity(0.75),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(0.0),
                                      hintText: 'Idade',
                                      labelStyle: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintStyle: TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 16.0,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.calendar_month,
                                        color: AppColor.primary,
                                        size: 26,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 2),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      floatingLabelStyle: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: AppColor.primary
                                                .withOpacity(0.75),
                                            width: 1.5),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Meses',
                                      groupValue: valueIdade,
                                      onChanged: (String? value) {
                                        setState(() {
                                          valueIdade = value!;
                                        });
                                      },
                                    ),
                                    Text('Meses')
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<String>(
                                      value: 'Anos',
                                      groupValue: valueIdade,
                                      onChanged: (String? value) {
                                        setState(() {
                                          valueIdade = value!;
                                        });
                                      },
                                    ),
                                    Text('Anos')
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                processoDeAtivacao();
                              },
                              child:
                                  BlocBuilder<ActivationBloc, ActivationState>(
                                bloc: _activationBloc,
                                builder: (context, state) {
                                  if (state is ActivationInitial) {
                                    return const Text(
                                      'Ativar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    );
                                  } else if (state is ActivationLoading) {
                                    return const Box4PetsLoader();
                                  } else {
                                    return const Text(
                                      'Ativar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            Positioned(
                top: 60,
                left: 15,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 30,
                    color: AppColor.primary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ))
          ],
        ),
      ),
    );
  }
}
