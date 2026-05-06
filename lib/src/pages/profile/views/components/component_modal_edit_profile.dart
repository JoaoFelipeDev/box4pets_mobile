// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/profile/models/profile_editing_model.dart';
import 'package:get_storage/get_storage.dart';

class ComponentModalEditProfile extends StatefulWidget {
  final void Function(ProfileEditingModel profile) editingProfile;
  const ComponentModalEditProfile({
    Key? key,
    required this.editingProfile,
  }) : super(key: key);

  @override
  State<ComponentModalEditProfile> createState() =>
      _ComponentModalEditProfileState();
}

class _ComponentModalEditProfileState extends State<ComponentModalEditProfile> {
  final box = GetStorage();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  TextEditingController controllerName = TextEditingController();

  final controllerPhone = MaskedTextController(mask: '(00) 0 0000-0000');
  final controllerCep = MaskedTextController(mask: '00000-000');
  String endereco = '';
  String function = '';
  String numero = '';
  editarUsuario() {
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String userId = user.id;
    final ProfileEditingModel userEdit = ProfileEditingModel(
      email: controllerEmail.text.isEmpty ? user.email : controllerEmail.text,
      endereco: endereco.isEmpty ? user.endereco : endereco,
      id: userId,
      nome: controllerName.text.isEmpty ? user.name : controllerName.text,
      perfil: function.isEmpty ? user.perfil : function,
      telefone:
          controllerPhone.text.isEmpty ? user.telefone : controllerPhone.text,
    );
   
    widget.editingProfile(userEdit);
    Navigator.pop(context);
  }

  getCep(String cep) async {
    String value = cep.replaceAll('-', '');
    final dio = Dio();
    try {
      final Response<dynamic> response =
          await dio.get('https://viacep.com.br/ws/$value/json/');

      if (response.data['erro'] != null) {
        const snackBar = SnackBar(
          content: Text('Digite um cep válido'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          endereco =
              ' ${response.data['logradouro']}, $numero, ${response.data['bairro']}, ${response.data['localidade']} - ${response.data['uf']}';
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'Editar perfil',
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextFormField(
                      controller: controllerEmail,
                      cursorColor: AppColor.primary.withOpacity(0.75),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        hintText: 'Email',
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
                          Icons.person_outline,
                          color: AppColor.primary,
                          size: 26,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 2),
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
                      controller: controllerName,
                      cursorColor: AppColor.primary.withOpacity(0.75),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        hintText: 'Seu nome',
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
                          Icons.account_box_outlined,
                          color: AppColor.primary,
                          size: 26,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 2),
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
                      controller: controllerPhone,
                      cursorColor: AppColor.primary.withOpacity(0.75),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        hintText: 'Telefone',
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
                          Icons.phone_android,
                          color: AppColor.primary,
                          size: 26,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.grey.shade200, width: 2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: const Color(0xffFFFFFF),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextFormField(
                            onChanged: (value) {
                              if (value.length >= 9) {
                                getCep(value);
                              }
                            },
                            controller: controllerCep,
                            cursorColor: AppColor.primary.withOpacity(0.75),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(0.0),
                              hintText: 'Digite seu cep',
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
                                Icons.location_city_outlined,
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
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 130,
                        decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              numero = value;
                            });
                            getCep(controllerCep.text);
                          },
                          cursorColor: AppColor.primary.withOpacity(0.75),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0.0),
                            hintText: 'Número',
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
                              Icons.numbers,
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
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    endereco,
                    style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const Divider(),
                  const SizedBox(
                    width: 24,
                  ),
                  Text(
                    'Escolha sua função',
                    style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: function == 'Tutor'
                                      ? AppColor.secondary
                                      : AppColor.primary,
                                  width: 2)),
                          onPressed: () {
                            setState(() {
                              function = 'Tutor';
                            });
                          },
                          child: Text(
                            'Tutor',
                            style: TextStyle(
                                color: function == 'Tutor'
                                    ? AppColor.secondary
                                    : AppColor.primary,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: function == 'Criador'
                                      ? AppColor.secondary
                                      : AppColor.primary,
                                  width: 2)),
                          onPressed: () {
                            setState(() {
                              function = 'Criador';
                            });
                          },
                          child: Text(
                            'Criador',
                            style: TextStyle(
                                color: function == 'Criador'
                                    ? AppColor.secondary
                                    : AppColor.primary,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: function == 'Médico Veterinário'
                                      ? AppColor.secondary
                                      : AppColor.primary,
                                  width: 2)),
                          onPressed: () {
                            setState(() {
                              function = 'Médico Veterinário';
                            });
                          },
                          child: Text(
                            'Médico Veterinário',
                            style: TextStyle(
                                color: function == 'Médico Veterinário'
                                    ? AppColor.secondary
                                    : AppColor.primary,
                                fontSize: 18),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        editarUsuario();
                      },
                      child: const Text('Editar'))
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
