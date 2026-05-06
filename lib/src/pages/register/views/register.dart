import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/src/pages/register/bloc/register_bloc.dart';
import 'package:Box4Pets/src/pages/register/models/register_model.dart';
import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final RegisterBloc _registerBloc;
  bool enderecoSelecionado = false;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  TextEditingController controllerName = TextEditingController();

  final controllerPhone = MaskedTextController(mask: '(00) 0 0000-0000');
  final controllerCep = MaskedTextController(mask: '00000-000');
  String endereco = '';
  String function = '';
  String numero = '';

  validarPrimeiroPasso() {
    String email = controllerEmail.text;
    String password = controllerSenha.text;
    String nome = controllerName.text;
    String phone = controllerPhone.text;
    String cep = controllerCep.text;
    String number = numero;

    if (email.isEmpty &&
        password.isEmpty &&
        number.isEmpty &&
        nome.isEmpty &&
        phone.isEmpty &&
        cep.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor preencha os dados!'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (email.isEmpty && password.isNotEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Email)!'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (email.isNotEmpty && password.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Senha)!'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (!email.contains('@') && !email.contains('.com')) {
      const snackBar = SnackBar(
        content: Text('Por favor, digite um e-mail válido'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (password.length < 6) {
      const snackBar = SnackBar(
        content: Text('Senha deve ter no minimo 6 caracteres'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (cep.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite o campo CEP'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (!enderecoSelecionado) {
      const snackBar = SnackBar(
        content: Text('Por favor digite um cep válido'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (number.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor digite o numero'),
      );
      return ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
     
      final RegisterModel register = RegisterModel(
          nome: nome,
          perfil: function,
          email: email,
          password: password,
          telefone: phone,
          endereco: endereco,
          active: true,
          CEP: int.parse(cep.replaceAll('-', '')));
    
      _registerBloc.add(RegisterEventRegister(register: register));
    }
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
          enderecoSelecionado = true;
          endereco =
              ' ${response.data['logradouro']}, $numero, ${response.data['bairro']}, ${response.data['localidade']} - ${response.data['uf']}';
        });
      }
    } catch (e) {}
  }

  @override
  void initState() {
    _registerBloc = RegisterBloc();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterBloc, RegisterState>(
        bloc: _registerBloc,
        listener: (context, state) {
          if (state is RegisterError) {
            final snackBar = SnackBar(
              content: Text(state.messageError),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 18, left: 18, top: 80),
          child: SingleChildScrollView(
            child: BlocListener<RegisterBloc, RegisterState>(
              bloc: _registerBloc,
              listener: (context, state) {
                if (state is RegisterLoaded) {
                  Navigator.popAndPushNamed(context, '/base');
                }
              },
              child: Column(
                children: [
                  Text(
                    'Cadastre-se',
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
                      controller: controllerSenha,
                      obscureText: true,
                      cursorColor: AppColor.primary.withOpacity(0.75),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(0.0),
                        hintText: 'Senha',
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
                          Icons.lock_outline,
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
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        validarPrimeiroPasso();
                      },
                      child: BlocBuilder<RegisterBloc, RegisterState>(
                        bloc: _registerBloc,
                        builder: (context, state) {
                          if (state is RegisterLoading) {
                            return const Box4PetsLoader();
                          } else {
                            return const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Cadastrar',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Já tenho uma conta!',
                        style: TextStyle(fontSize: 18),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
