import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/service/util_service.dart';
import 'package:Box4Pets/src/pages/login/bloc/auth_bloc_bloc.dart';
import 'package:Box4Pets/src/pages/login/models/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final AuthBlocBloc _authBloc;
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerEmailRecover = TextEditingController();
  TextEditingController controllerSenha = TextEditingController();
  TextEditingController controllercode = TextEditingController();
  TextEditingController controllerNewPassword = TextEditingController();
  _modalRecuperarSenha(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Digite seu e-mail para recuperar a senha'),
              TextField(
                controller: controllerEmailRecover,
                decoration: const InputDecoration(
                  hintText: 'E-mail',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _findEmail(controllerEmailRecover.text);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
  validarAuth() {
    String email = controllerEmail.text;
    String password = controllerSenha.text;

    if (email.isEmpty && password.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha os campos (Email e Senha)!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (email.isEmpty && password.isNotEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Email)!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (email.isNotEmpty && password.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Senha)!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (!email.contains('@') && !email.contains('.com')) {
      const snackBar = SnackBar(
        content: Text('Por favor, digite um e-mail válido'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (password.length < 6) {
      const snackBar = SnackBar(
        content: Text('Senha deve ter no minimo 6 caracteres'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _authBloc.add(AuthEvent(auth: AuthModel(email: email, senha: password)));
    }
  }

  _modalChangePassword(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recuperar Senha', textAlign: TextAlign.center,),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Digite a nova senha'),
              TextField(
                controller: controllerNewPassword,
                decoration: const InputDecoration(
                  hintText: 'Nova Senha',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
               validadeChangePassword(controllerNewPassword.text, controllercode.text);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  validadeChangePassword(String password, String code){
    if (password.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Nova Senha)!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _authBloc.add(AuthChangePasswordEvent(password: password, code: code));
    }
  }
    avaliarCheckCode(String code) {
    if (code.isEmpty) {
      const snackBar = SnackBar(
        content: Text('Por favor, preencha o campo (Código)!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _authBloc.add(AuthCheckCodeEvent(code: code));
    }
    }

  _modalCheckCode(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Digite o código enviado para o seu e-mail'),
              TextField(
                controller: controllercode,
                decoration: const InputDecoration(
                  hintText: 'Código',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                avaliarCheckCode(controllercode.text);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
  _sendCodeEmail(String email, String code){
    String emailBody = generateEmailBody(code);
    UtilService().sendEmail(email: email, body: emailBody);
  }
  String generateUniqueCode() {
  var uuid = Uuid();
  return uuid.v4();
}

String generateEmailBody(String code) {
   return '''
  <!DOCTYPE html>
  <html>
  <head>
    <style>
      .container {
        font-family: Arial, sans-serif;
        margin: 20px;
      }
      .code {
        font-size: 24px;
        font-weight: bold;
        margin: 20px 0;
      }
      .button {
        background-color: #4CAF50;
        color: white;
        padding: 10px 20px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 16px;
        margin: 4px 2px;
        cursor: pointer;
        border: none;
        border-radius: 5px;
      }
      .image {
        margin-top: 20px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h2>Código de Recuperação de Senha</h2>
      <p>Use o código abaixo para recuperar sua senha:</p>
      <div class="code">$code</div>
      <p>Copie o código acima e cole no campo de recuperação de senha.</p>
      <div class="image">
        <img src="https://box4pets.com.br/cdn/shop/files/tela2_solto_800x.png?v=1692061684" alt="Box4Pets">
      </div>
    </div>
  </body>
  </html>
  ''';
}

_findEmail(String email){
  _authBloc.add(AuthForgotPasswordEvent(email: email));
}

  @override
  void initState() {
    _authBloc = AuthBlocBloc();

    super.initState();
  }

  Widget build(BuildContext context) {
    return BlocListener<AuthBlocBloc, AuthBlocState>(
      bloc: _authBloc,
      listener: (context, state) {
        if (state is AuthBlocLoaded) {
          if (state.isAuthenticated) {
            Navigator.popAndPushNamed(context, '/base');
          }
        } else if (state is AuthBlocError) {
          final snackBar = SnackBar(
            content: Text(state.messageError),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);

        }else if(state is AuthBlocForgotPassword){
         
            _sendCodeEmail(state.email, state.code);
            final snackBar = SnackBar(
              content: const Text('Email enviado com sucesso!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            _modalCheckCode();
        }else if(state is AuthBlocCheckCode){
          if(state.isValid){
            _modalChangePassword();
          }else{
            final snackBar = SnackBar(
              content: const Text('Código inválido!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

        }else if(state is AuthBlocChangePassword){
         if(state.isChanged){
            final snackBar = SnackBar(
              content: const Text('Senha alterada com sucesso!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }else{
            final snackBar = SnackBar(
              content: const Text('Erro ao alterar senha!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }

        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 100, left: 30, right: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColor.primary,
                      fontSize: 36),
                ),
                const SizedBox(
                  height: 20,
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
                      validarAuth();
                    },
                    child: BlocBuilder<AuthBlocBloc, AuthBlocState>(
                      bloc: _authBloc,
                      builder: (context, state) {
                        if (state is AuthBlocLoading) {
                          return const Box4PetsLoader();
                        } else {
                          return const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Entrar',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white,)
                            ],
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ainda não tem cadastro?',
                        style: TextStyle(
                            fontSize: 18.78, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text(
                            'Criar',
                            style: TextStyle(
                                color: AppColor.primary,
                                fontSize:
                                    MediaQuery.of(context).size.width * .04,
                                fontWeight: FontWeight.w900),
                          ))
                    ],
                  ),
                ),
               
                // Esqueceu a senha
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Esqueceu a senha?',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    
                    TextButton(
                        onPressed: () {
                         _modalRecuperarSenha();
                        
                        },
                        child: Text(
                          'Recuperar',
                          style: TextStyle(
                              color: AppColor.primary,
                              fontSize:
                                  14,
                              fontWeight: FontWeight.w900),
                        ))
                  ],
                ),
                Image.asset('assets/images/tela5 4.png')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
