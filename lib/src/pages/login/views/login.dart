import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/welcome_transition.dart';
import 'package:Box4Pets/service/util_service.dart';
import 'package:Box4Pets/src/pages/base/base.dart';
import 'package:Box4Pets/src/pages/login/bloc/auth_bloc_bloc.dart';
import 'package:Box4Pets/src/pages/login/models/auth_model.dart';
import 'package:Box4Pets/src/pages/register/views/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final AuthBlocBloc _authBloc;
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerEmailRecover = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  final TextEditingController controllercode = TextEditingController();
  final TextEditingController controllerNewPassword = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBlocBloc();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerEmailRecover.dispose();
    controllerSenha.dispose();
    controllercode.dispose();
    controllerNewPassword.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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

  void _validarAuth() {
    final email = controllerEmail.text;
    final password = controllerSenha.text;

    if (email.isEmpty && password.isEmpty) {
      return _showError('Preencha email e senha');
    } else if (email.isEmpty) {
      return _showError('Preencha o email');
    } else if (password.isEmpty) {
      return _showError('Preencha a senha');
    } else if (!email.contains('@') || !email.contains('.')) {
      return _showError('Digite um email válido');
    } else if (password.length < 6) {
      return _showError('Senha precisa ter ao menos 6 caracteres');
    }
    HapticFeedback.mediumImpact();
    _authBloc.add(AuthEvent(auth: AuthModel(email: email, senha: password)));
  }

  void _openSheet(_SimpleAuthSheet sheet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => sheet,
    );
  }

  void _openRecoverPassword() {
    _openSheet(_SimpleAuthSheet(
      title: 'Recuperar senha',
      subtitle: 'Digite seu email para receber o código',
      hint: 'Email',
      icon: Icons.mail_outline_rounded,
      controller: controllerEmailRecover,
      onConfirm: (value) {
        Navigator.pop(context);
        if (value.isEmpty) {
          _showError('Digite seu email');
          return;
        }
        _authBloc.add(AuthForgotPasswordEvent(email: value));
      },
    ));
  }

  void _openCheckCode() {
    _openSheet(_SimpleAuthSheet(
      title: 'Verificar código',
      subtitle: 'Digite o código que recebeu no email',
      hint: 'Código',
      icon: Icons.vpn_key_rounded,
      controller: controllercode,
      onConfirm: (value) {
        Navigator.pop(context);
        if (value.isEmpty) {
          _showError('Digite o código');
          return;
        }
        _authBloc.add(AuthCheckCodeEvent(code: value));
      },
    ));
  }

  void _openChangePassword() {
    _openSheet(_SimpleAuthSheet(
      title: 'Nova senha',
      subtitle: 'Crie uma nova senha para sua conta',
      hint: 'Nova senha',
      icon: Icons.lock_outline_rounded,
      controller: controllerNewPassword,
      obscure: true,
      onConfirm: (value) {
        Navigator.pop(context);
        if (value.isEmpty) {
          _showError('Digite a nova senha');
          return;
        }
        _authBloc.add(
            AuthChangePasswordEvent(password: value, code: controllercode.text));
      },
    ));
  }

  void _sendCodeEmail(String email, String code) {
    UtilService().sendEmail(email: email, body: _generateEmailBody(code));
  }

  String _generateEmailBody(String code) {
    return '''
<!DOCTYPE html>
<html>
<head><style>
.container { font-family: Arial, sans-serif; margin: 20px; }
.code { font-size: 24px; font-weight: bold; margin: 20px 0; }
</style></head>
<body>
<div class="container">
<h2>Código de Recuperação de Senha</h2>
<p>Use o código abaixo para recuperar sua senha:</p>
<div class="code">$code</div>
<p>Copie o código acima e cole no campo de recuperação de senha.</p>
</div>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topInset = MediaQuery.of(context).padding.top;
    final imageHeight = size.height * 0.42;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: BlocListener<AuthBlocBloc, AuthBlocState>(
        bloc: _authBloc,
        listener: (context, state) {
          if (state is AuthBlocLoaded) {
            if (state.isAuthenticated) {
              Navigator.of(context).pushAndRemoveUntil(
                WelcomePageRoute(page: const Base()),
                (_) => false,
              );
            } else {
              _showError('Email ou senha inválidos');
            }
          } else if (state is AuthBlocError) {
            _showError(state.messageError);
          } else if (state is AuthBlocForgotPassword) {
            _sendCodeEmail(state.email, state.code);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email enviado com sucesso')),
            );
            _openCheckCode();
          } else if (state is AuthBlocCheckCode) {
            if (state.isValid) {
              _openChangePassword();
            } else {
              _showError('Código inválido');
            }
          } else if (state is AuthBlocChangePassword) {
            if (state.isChanged) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Senha alterada com sucesso')),
              );
            } else {
              _showError('Erro ao alterar senha');
            }
          }
        },
        child: Stack(
          children: [
            // Imagem fixa de fundo (não scrolla)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/login_bg.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.25),
                          Colors.black.withOpacity(0.12),
                          Colors.black.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Logo branco sobreposto na imagem
            Positioned(
              top: topInset + 36,
              left: 0,
              right: 0,
              child: Center(
                child: SvgPicture.asset(
                  'assets/logoB4p.svg',
                  height: 40,
                  colorFilter: const ColorFilter.mode(
                      Colors.white, BlendMode.srcIn),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 380.ms)
                .scale(
                    begin: const Offset(0.92, 0.92),
                    duration: 380.ms,
                    curve: Curves.easeOutBack),
            // Form scrollável que sobe sobre a imagem
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: imageHeight - 40),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Entrar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 26,
                            letterSpacing: -0.7,
                            height: 1.1,
                          ),
                        )
                            .animate(delay: 120.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 6),
                        Text(
                          'Entre na sua conta pra continuar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            color: AppColor.primary.withOpacity(0.55),
                            fontSize: 13.5,
                          ),
                        ).animate(delay: 180.ms).fadeIn(duration: 380.ms),
                        const SizedBox(height: 24),
                        _AuthField(
                          controller: controllerEmail,
                          hint: 'Email',
                          icon: Icons.mail_outline_rounded,
                          keyboard: TextInputType.emailAddress,
                        )
                            .animate(delay: 220.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 10),
                        _AuthField(
                          controller: controllerSenha,
                          hint: 'Senha',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscurePassword,
                          suffix: GestureDetector(
                            onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColor.primary.withOpacity(0.55),
                              ),
                            ),
                          ),
                        )
                            .animate(delay: 280.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _openRecoverPassword,
                            child: Text(
                              'Esqueceu a senha?',
                              style: GoogleFonts.dmSans(
                                color: AppColor.primary.withOpacity(0.7),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ).animate(delay: 340.ms).fadeIn(duration: 380.ms),
                        const SizedBox(height: 6),
                        BlocBuilder<AuthBlocBloc, AuthBlocState>(
                          bloc: _authBloc,
                          builder: (context, state) {
                            final loading = state is AuthBlocLoading;
                            return GestureDetector(
                              onTap: loading ? null : _validarAuth,
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
                                      color:
                                          AppColor.primary.withOpacity(0.35),
                                      blurRadius: 22,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        loading ? 'Entrando...' : 'Entrar',
                                        style: GoogleFonts.dmSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      if (!loading) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward_rounded,
                                            color: Colors.white, size: 18),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 420.ms)
                            .slideY(begin: 0.1, end: 0),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Ainda não tem cadastro?',
                              style: GoogleFonts.archivo(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColor.primary.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_) => const Register(),
                                ),
                              ),
                              child: Text(
                                'Criar conta',
                                style: GoogleFonts.dmSans(
                                  color: AppColor.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ).animate(delay: 460.ms).fadeIn(duration: 380.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final Widget? suffix;
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboard,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 6),
            child: Icon(icon,
                color: AppColor.primary.withOpacity(0.55), size: 18),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboard,
              cursorColor: AppColor.primary,
              style: GoogleFonts.archivo(
                color: AppColor.primary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColor.primary.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

class _SimpleAuthSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final void Function(String) onConfirm;
  const _SimpleAuthSheet({
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onConfirm,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 10, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              color: AppColor.primary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              color: AppColor.primary.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: AppColor.primary.withOpacity(0.55), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    autofocus: true,
                    cursorColor: AppColor.primary,
                    style: GoogleFonts.archivo(
                      color: AppColor.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: AppColor.primary.withOpacity(0.45),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onConfirm(controller.text.trim());
            },
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
                    color: AppColor.primary.withOpacity(0.32),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Confirmar',
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
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: AppColor.primary.withOpacity(0.55),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
