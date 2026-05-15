import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/cupertino_wheel_picker.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/register/bloc/register_bloc.dart';
import 'package:Box4Pets/src/pages/register/models/register_model.dart';
import 'package:dio/dio.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final RegisterBloc _registerBloc;
  bool enderecoSelecionado = false;
  bool _obscurePassword = true;
  bool _loadingCep = false;

  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final controllerPhone = MaskedTextController(mask: '(00) 0 0000-0000');
  final controllerCep = MaskedTextController(mask: '00000-000');
  final TextEditingController controllerNumero = TextEditingController();

  String endereco = '';
  String function = '';
  String numero = '';

  static const List<String> _functions = [
    'Tutor',
    'Criador',
    'Médico Veterinário',
  ];

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc();
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerSenha.dispose();
    controllerName.dispose();
    controllerPhone.dispose();
    controllerCep.dispose();
    controllerNumero.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        if (mounted) _showError('Digite um CEP válido');
      } else if (mounted) {
        setState(() {
          enderecoSelecionado = true;
          endereco =
              '${response.data['logradouro']}, $numero, ${response.data['bairro']}, ${response.data['localidade']} - ${response.data['uf']}';
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingCep = false);
  }

  void _validar() {
    final email = controllerEmail.text;
    final password = controllerSenha.text;
    final nome = controllerName.text;
    final phone = controllerPhone.text;
    final cep = controllerCep.text;
    final number = numero;

    if (nome.isEmpty) return _showError('Digite seu nome');
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      return _showError('Digite um email válido');
    }
    if (password.length < 6) {
      return _showError('Senha precisa ter ao menos 6 caracteres');
    }
    if (phone.isEmpty) return _showError('Digite seu telefone');
    if (cep.isEmpty) return _showError('Digite seu CEP');
    if (!enderecoSelecionado) return _showError('CEP inválido');
    if (number.isEmpty) return _showError('Digite o número da casa');
    if (function.isEmpty) return _showError('Selecione sua função');

    HapticFeedback.mediumImpact();
    final register = RegisterModel(
      nome: nome,
      perfil: function,
      email: email,
      password: password,
      telefone: phone,
      endereco: endereco,
      active: true,
      CEP: int.parse(cep.replaceAll('-', '')),
    );
    _registerBloc.add(RegisterEventRegister(register: register));
  }

  Future<void> _pickFunction() async {
    final selected = await showCupertinoWheelPicker(
      context: context,
      title: 'Você é',
      items: _functions,
      selected: function.isEmpty ? null : function,
    );
    if (selected != null) setState(() => function = selected);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: BlocListener<RegisterBloc, RegisterState>(
          bloc: _registerBloc,
          listener: (context, state) {
            if (state is RegisterLoaded) {
              Navigator.popAndPushNamed(context, '/base');
            } else if (state is RegisterError) {
              _showError(state.messageError);
            }
          },
          child: Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          'assets/logoB4p.svg',
                          height: 32,
                        ),
                      ).animate().fadeIn(duration: 320.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          duration: 320.ms,
                          curve: Curves.easeOutBack),
                      const SizedBox(height: 22),
                      Text(
                        'Criar conta',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          letterSpacing: -0.7,
                          height: 1.1,
                        ),
                      )
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 4),
                      Text(
                        'Preencha seus dados pra começar',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivo(
                          color: AppColor.primary.withOpacity(0.55),
                          fontSize: 13,
                        ),
                      ).animate(delay: 140.ms).fadeIn(duration: 320.ms),
                      const SizedBox(height: 22),
                      _Section(
                        title: 'Conta',
                        children: [
                          _Field(
                            controller: controllerName,
                            hint: 'Nome completo',
                            icon: Icons.person_outline_rounded,
                          ),
                          _Field(
                            controller: controllerEmail,
                            hint: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboard: TextInputType.emailAddress,
                          ),
                          _Field(
                            controller: controllerSenha,
                            hint: 'Senha',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscurePassword,
                            suffix: GestureDetector(
                              onTap: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColor.primary.withOpacity(0.55),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).animate(delay: 200.ms).fadeIn(duration: 380.ms).slideY(
                          begin: 0.05, end: 0),
                      const SizedBox(height: 14),
                      _Section(
                        title: 'Contato',
                        children: [
                          _Field(
                            controller: controllerPhone,
                            hint: 'Telefone',
                            icon: Icons.phone_iphone_rounded,
                            keyboard: TextInputType.phone,
                          ),
                        ],
                      )
                          .animate(delay: 260.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 14),
                      _Section(
                        title: 'Endereço',
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _Field(
                                  controller: controllerCep,
                                  hint: 'CEP',
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
                                  hint: 'Número',
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
                                  const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                                        color: AppColor.primary
                                            .withOpacity(0.7),
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
                      )
                          .animate(delay: 320.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.05, end: 0),
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
                      )
                          .animate(delay: 380.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.05, end: 0),
                      const SizedBox(height: 28),
                      BlocBuilder<RegisterBloc, RegisterState>(
                        bloc: _registerBloc,
                        builder: (context, state) {
                          final loading = state is RegisterLoading;
                          return GestureDetector(
                            onTap: loading ? null : _validar,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              height: 58,
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
                                    color: AppColor.primary
                                        .withOpacity(0.35),
                                    blurRadius: 22,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      loading ? 'Criando...' : 'Criar conta',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    if (!loading) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                          .animate(delay: 440.ms)
                          .fadeIn(duration: 420.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 18),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Já tem cadastro?',
                              style: GoogleFonts.archivo(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColor.primary.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Entrar',
                                style: GoogleFonts.dmSans(
                                  color: AppColor.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: 500.ms).fadeIn(duration: 380.ms),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: topInset + 8,
                left: 14,
                child: _GlassIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
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
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboard;
  final void Function(String)? onChanged;
  final bool obscure;
  final Widget? suffix;
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboard,
    this.onChanged,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
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
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(minWidth: 0),
          hintText: hint,
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
      padding: const EdgeInsets.symmetric(vertical: 5),
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
              Icon(icon,
                  color: AppColor.primary.withOpacity(0.6), size: 18),
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Icon(icon, color: AppColor.primary, size: 16),
          ),
        ),
      ),
    );
  }
}
