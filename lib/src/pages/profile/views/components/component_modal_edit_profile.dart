import 'dart:convert';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/cupertino_wheel_picker.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/profile/models/profile_editing_model.dart';
import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final UserActivationModel _user;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final controllerPhone = MaskedTextController(mask: '(00) 0 0000-0000');
  final controllerCep = MaskedTextController(mask: '00000-000');
  final TextEditingController controllerNumero = TextEditingController();

  String endereco = '';
  String function = '';
  String numero = '';
  bool _loadingCep = false;

  static const List<String> _functions = [
    'Tutor',
    'Criador',
    'Médico Veterinário',
  ];

  @override
  void initState() {
    super.initState();
    final json = box.read('user');
    _user = UserActivationModel.fromJson(jsonDecode(json));
    controllerEmail.text = _user.email;
    controllerName.text = _user.name;
    controllerPhone.text = _user.telefone;
    endereco = _user.endereco;
    function = _user.perfil;
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerName.dispose();
    controllerPhone.dispose();
    controllerCep.dispose();
    controllerNumero.dispose();
    super.dispose();
  }

  Future<void> _getCep(String cep) async {
    final value = cep.replaceAll('-', '');
    if (value.length != 8) return;
    setState(() => _loadingCep = true);
    final dio = Dio();
    try {
      final response =
          await dio.get('https://viacep.com.br/ws/$value/json/');
      if (response.data['erro'] != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Digite um CEP válido')),
        );
      } else {
        setState(() {
          endereco =
              '${response.data['logradouro']}, $numero, ${response.data['bairro']}, ${response.data['localidade']} - ${response.data['uf']}';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingCep = false);
  }

  void _save() {
    final updated = ProfileEditingModel(
      email: controllerEmail.text.isEmpty ? _user.email : controllerEmail.text,
      endereco: endereco.isEmpty ? _user.endereco : endereco,
      id: _user.id,
      nome: controllerName.text.isEmpty ? _user.name : controllerName.text,
      perfil: function.isEmpty ? _user.perfil : function,
      telefone:
          controllerPhone.text.isEmpty ? _user.telefone : controllerPhone.text,
    );
    HapticFeedback.mediumImpact();
    widget.editingProfile(updated);
    Navigator.pop(context);
  }

  Future<void> _pickFunction() async {
    final selected = await showCupertinoWheelPicker(
      context: context,
      title: 'Função',
      items: _functions,
      selected: function.isEmpty ? null : function,
    );
    if (selected != null) {
      setState(() => function = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFAF8FF),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Editar perfil',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: AppColor.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Atualize suas informações',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivo(
                              color: AppColor.primary.withOpacity(0.55),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _Section(
                          title: 'Conta',
                          children: [
                            _Field(
                              controller: controllerName,
                              label: 'Seu nome',
                              icon: Icons.person_outline_rounded,
                            ),
                            _Field(
                              controller: controllerEmail,
                              label: 'Email',
                              icon: Icons.mail_outline_rounded,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _Field(
                              controller: controllerPhone,
                              label: 'Telefone',
                              icon: Icons.phone_iphone_rounded,
                              keyboard: TextInputType.phone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'Endereço',
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _Field(
                                    controller: controllerCep,
                                    label: 'CEP',
                                    icon: Icons.location_on_outlined,
                                    keyboard: TextInputType.number,
                                    onChanged: (v) {
                                      if (v.length >= 9) _getCep(v);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: _Field(
                                    controller: controllerNumero,
                                    label: 'Número',
                                    icon: Icons.numbers_rounded,
                                    keyboard: TextInputType.number,
                                    onChanged: (v) {
                                      numero = v;
                                      if (controllerCep.text.length >= 9) {
                                        _getCep(controllerCep.text);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (endereco.isNotEmpty || _loadingCep)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(4, 8, 4, 4),
                                child: Row(
                                  children: [
                                    if (_loadingCep)
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColor.primary
                                                      .withOpacity(0.7)),
                                        ),
                                      ),
                                    if (_loadingCep) const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _loadingCep
                                            ? 'Buscando endereço...'
                                            : endereco,
                                        style: GoogleFonts.archivo(
                                          color:
                                              AppColor.primary.withOpacity(0.7),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _Section(
                          title: 'Função',
                          children: [
                            _PickerField(
                              label: 'Você é',
                              icon: Icons.badge_outlined,
                              value: function,
                              placeholder: 'Selecionar função',
                              onTap: _pickFunction,
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 12,
                child: IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppColor.primary.withOpacity(0.6)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Positioned(
                bottom: 18,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _save,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.primary,
                          AppColor.primary.withOpacity(0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Salvar',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppColor.primary.withOpacity(0.55),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboard;
  final void Function(String)? onChanged;
  final bool obscure;
  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboard,
    this.onChanged,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        onChanged: onChanged,
        cursorColor: AppColor.primary,
        style: GoogleFonts.archivo(
          color: AppColor.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF3EEFC).withOpacity(0.7),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child:
                Icon(icon, color: AppColor.primary.withOpacity(0.6), size: 18),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0),
          hintText: label,
          hintStyle: TextStyle(
            color: AppColor.primary.withOpacity(0.45),
            fontWeight: FontWeight.w500,
            fontSize: 13.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColor.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String placeholder;
  final VoidCallback onTap;
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EEFC).withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColor.primary.withOpacity(0.6), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColor.primary.withOpacity(0.55),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value : placeholder,
                      style: GoogleFonts.archivo(
                        color: hasValue
                            ? AppColor.primary
                            : AppColor.primary.withOpacity(0.45),
                        fontWeight: hasValue
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColor.primary.withOpacity(0.45), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimplePickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selected;
  const _SimplePickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: AppColor.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),
          for (final opt in options)
            InkWell(
              onTap: () => Navigator.pop(context, opt),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: opt == selected
                      ? AppColor.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.archivo(
                          color: AppColor.primary,
                          fontSize: 15,
                          fontWeight: opt == selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (opt == selected)
                      Icon(Icons.check_rounded,
                          color: AppColor.primary, size: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
