import 'dart:convert';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/login/views/login.dart';
import 'package:Box4Pets/src/pages/profile/bloc/profile_bloc.dart';
import 'package:Box4Pets/src/pages/profile/models/change_password_model.dart';
import 'package:Box4Pets/src/pages/profile/models/profile_editing_model.dart';
import 'package:Box4Pets/src/pages/profile/views/components/component_modal_edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordAgainController = TextEditingController();
  final box = GetStorage();
  late final ProfileBloc _profileBloc;

  logout() {
    box.remove('user');
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  editingProfile(ProfileEditingModel profile) {
    _profileBloc.add(ProfileEditingEvent(profile: profile));
  }

  changePassword(){
    String password = passwordController.text;
    String passwordAgain = passwordAgainController.text;
    String json = box.read('user');
    UserActivationModel user = UserActivationModel.fromJson(jsonDecode(json));
    String userId = user.id;

    if(password == passwordAgain){
      _profileBloc.add(ProfileChangePasswordEvent(password: ChangePasswordmodel(password: password, id: userId  )));
      passwordController.clear();
      passwordAgainController.clear();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('As senhas não são iguais')));
      passwordController.clear();
      passwordAgainController.clear();
    }
    
  }
openModalChangePassword(){
  return showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Deseja alterar sua senha?',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
             
             
               const SizedBox(
                height: 14,
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                    hintText: 'Digite sua nova senha',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))),
              ),
               const SizedBox(
                height: 14,
              ),
              TextField(
                controller: passwordAgainController,
                decoration: InputDecoration(
                    hintText: 'Digite sua nova senha novamente',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30))),
              ),
              const SizedBox(
                height: 14,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Não',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        changePassword();
                      },
                      child: Text(
                        'Alterar',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ))
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
  openModalDeletAccount() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Deseja desativar sua conta?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Não',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        )),
                    TextButton(
                        onPressed: () {
                          _profileBloc.add(ProfileDeletAccountEvent());
                        },
                        child: Text(
                          'Sim',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  openModalEditProfile() {
    return showDialog(
      context: context,
      builder: (context) {
        return ComponentModalEditProfile(
          editingProfile: editingProfile,
        );
      },
    );
  }

  @override
  void initState() {
    _profileBloc = ProfileBloc();
    _profileBloc.add(ProfileGetEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      body: BlocListener<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        listener: (context, state) {
          if (state is ProfileDelet) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          }else if(state is ProfileChangePasswordSuccess){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            _profileBloc.add(ProfileGetEvent());
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          builder: (context, state) {
            if (state is ProfileLoaded) {
              return SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(state.proile.url ??
                                'https://cdn1.iconfinder.com/data/icons/project-management-8/500/worker-512.png'),
                          ),
                          // Positioned(
                          //     bottom: 0,
                          //     right: 0,
                          //     child: Container(
                          //       decoration: BoxDecoration(
                          //         color: AppColor.primary,
                          //         borderRadius: BorderRadius.circular(100),
                          //       ),
                          //       child: IconButton(
                          //         onPressed: () {
                          //           getImageGalery();
                          //         },
                          //         icon: const Icon(
                          //           Icons.add,
                          //           color: Colors.white,
                          //         ),
                          //       ),
                          //     ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    Text(
                      state.proile.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary,
                          fontSize: 18),
                    ),
                    const SizedBox(
                      height: 19,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColor.secondary,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        state.proile.perfil,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Divider(
                      color: AppColor.primary,
                      height: 10,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Card(
                      elevation: 10,
                      color: const Color(0xffDADADA),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mail_outline,
                              color: AppColor.primary,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              state.proile.email,
                              style: TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Card(
                      elevation: 10,
                      color: const Color(0xffDADADA),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: AppColor.primary,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: 200,
                              child: Text(
                                maxLines: 4,
                                state.proile.telefone,
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Card(
                      elevation: 10,
                      color: const Color(0xffDADADA),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColor.primary,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            SizedBox(
                              width: 250,
                              child: Text(
                                maxLines: 4,
                                state.proile.endereco,
                                style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.secondary),
                          onPressed: () {
                            openModalChangePassword();
                          },
                          child: const Text('Alterar Senha', style: TextStyle(color: Colors.white),)),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary),
                          onPressed: () {
                            openModalEditProfile();
                          },
                          child: const Text('Editar perfil', style: TextStyle(color: Colors.white),)),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red)),
                          onPressed: () {
                            logout();
                          },
                          child: const Text(
                            'Sair',
                            style: TextStyle(color: Colors.red),
                          )),
                    ),
                    // SizedBox(
                    //   width: double.infinity,
                    //   child: OutlinedButton(
                    //       style: OutlinedButton.styleFrom(
                    //           side: const BorderSide(color: Colors.black)),
                    //       onPressed: () {
                    //         openModalDeletAccount();
                    //       },
                    //       child: const Text(
                    //         'Desativar Conta',
                    //         style: TextStyle(color: Colors.black),
                    //       )),
                    // ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ));
            } else if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text("Error"));
            }
          },
        ),
      ),
    );
  }
}
