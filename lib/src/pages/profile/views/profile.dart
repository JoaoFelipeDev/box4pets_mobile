import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Box4Pets/src/pages/ativacao/models/user_activation_model.dart';
import 'package:Box4Pets/src/pages/login/views/login.dart';
import 'package:Box4Pets/src/pages/profile/bloc/profile_bloc.dart';
import 'package:Box4Pets/src/pages/profile/models/change_password_model.dart';
import 'package:Box4Pets/src/pages/profile/models/profile_editing_model.dart';
import 'package:Box4Pets/src/pages/profile/views/components/component_modal_edit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordAgainController =
      TextEditingController();
  final box = GetStorage();
  late final ProfileBloc _profileBloc;
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _profileBloc = ProfileBloc()..add(ProfileGetEvent());
    final saved = box.read('profile_photo_path');
    if (saved is String && saved.isNotEmpty && File(saved).existsSync()) {
      _localPhotoPath = saved;
    }
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PhotoSourceSheet(),
    );
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 800,
      );
      if (picked == null) return;
      setState(() => _localPhotoPath = picked.path);
      box.write('profile_photo_path', picked.path);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao acessar foto: $e')),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordAgainController.dispose();
    super.dispose();
  }

  void _logout() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Sair'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('Tem certeza que deseja sair da sua conta?'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              box.remove('user');
              Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _editingProfile(ProfileEditingModel profile) {
    _profileBloc.add(ProfileEditingEvent(profile: profile));
  }

  void _changePassword() {
    final password = _passwordController.text;
    final passwordAgain = _passwordAgainController.text;
    final json = box.read('user');
    final user = UserActivationModel.fromJson(jsonDecode(json));

    if (password == passwordAgain) {
      _profileBloc.add(ProfileChangePasswordEvent(
        password: ChangePasswordmodel(password: password, id: user.id),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não são iguais')),
      );
    }
    _passwordController.clear();
    _passwordAgainController.clear();
  }

  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ChangePasswordSheet(
        passwordController: _passwordController,
        passwordAgainController: _passwordAgainController,
        onConfirm: () {
          Navigator.pop(context);
          _changePassword();
        },
      ),
    );
  }

  void _openEditProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          ComponentModalEditProfile(editingProfile: _editingProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocListener<ProfileBloc, ProfileState>(
        bloc: _profileBloc,
        listener: (context, state) {
          if (state is ProfileDelet) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const Login()));
          } else if (state is ProfileChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            _profileBloc.add(ProfileGetEvent());
          }
        },
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: _profileBloc,
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Box4PetsLoader();
            }
            if (state is! ProfileLoaded) {
              return const SizedBox.shrink();
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 22),
                  _buildInfoSection(state),
                  const SizedBox(height: 18),
                  _buildActions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileLoaded state) {
    final hasRemoteUrl = state.proile.url != null &&
        state.proile.url!.isNotEmpty &&
        !state.proile.url!.contains('iconfinder');
    Widget avatarChild;
    if (_localPhotoPath != null) {
      avatarChild = Image.file(File(_localPhotoPath!),
          width: 84, height: 84, fit: BoxFit.cover);
    } else if (hasRemoteUrl) {
      avatarChild = Image.network(state.proile.url!,
          width: 84, height: 84, fit: BoxFit.cover);
    } else {
      avatarChild = Container(
        width: 84,
        height: 84,
        color: const Color(0xFFF3EEFC),
        child: Icon(Icons.person_outline_rounded,
            color: AppColor.primary.withOpacity(0.55), size: 40),
      );
    }
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColor.primary, AppColor.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ClipOval(child: avatarChild),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primary,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .scale(
                  begin: const Offset(0.85, 0.85),
                  duration: 380.ms,
                  curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 14),
          Text(
            state.proile.name,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
              letterSpacing: -0.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 80.ms).fadeIn(duration: 320.ms),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColor.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColor.secondary.withOpacity(0.3), width: 1),
            ),
            child: Text(
              state.proile.perfil,
              style: GoogleFonts.archivo(
                color: AppColor.secondary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.2,
              ),
            ),
          ).animate(delay: 140.ms).fadeIn(duration: 320.ms),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ProfileLoaded state) {
    return _GlassPanel(
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.mail_outline_rounded,
            label: 'Email',
            value: state.proile.email,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.phone_iphone_rounded,
            label: 'Telefone',
            value: state.proile.telefone,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Endereço',
            value: state.proile.endereco,
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 380.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildActions() {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.edit_outlined,
          label: 'Editar perfil',
          color: AppColor.primary,
          onTap: _openEditProfile,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.lock_outline_rounded,
          label: 'Alterar senha',
          color: AppColor.secondary,
          onTap: _openChangePassword,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.logout_rounded,
          label: 'Sair',
          color: Colors.red.shade400,
          danger: true,
          onTap: _logout,
        ),
      ],
    ).animate(delay: 280.ms).fadeIn(duration: 380.ms);
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColor.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary.withOpacity(0.5),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        height: 0.7,
        color: AppColor.primary.withOpacity(0.08),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool danger;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.55),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: danger ? color : AppColor.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: (danger ? color : AppColor.primary).withOpacity(0.4),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoSourceSheet extends StatelessWidget {
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
          20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Foto de perfil',
            style: GoogleFonts.dmSans(
              color: AppColor.primary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          _SourceOption(
            icon: Icons.camera_alt_rounded,
            label: 'Tirar foto',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const SizedBox(height: 8),
          _SourceOption(
            icon: Icons.photo_library_rounded,
            label: 'Escolher da galeria',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SourceOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEFC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColor.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.archivo(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColor.primary.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController passwordAgainController;
  final VoidCallback onConfirm;
  const _ChangePasswordSheet({
    required this.passwordController,
    required this.passwordAgainController,
    required this.onConfirm,
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
            'Alterar senha',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColor.primary,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crie uma nova senha pra sua conta',
            textAlign: TextAlign.center,
            style: GoogleFonts.archivo(
              color: AppColor.primary.withOpacity(0.55),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _PasswordField(
                    controller: passwordController,
                    hint: 'Nova senha',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _PasswordField(
                    controller: passwordAgainController,
                    hint: 'Confirme a nova senha',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              onConfirm();
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
                    color: AppColor.primary.withOpacity(0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Alterar',
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
          const SizedBox(height: 10),
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

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _PasswordField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
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
          child: Icon(Icons.lock_outline_rounded,
              color: AppColor.primary.withOpacity(0.6), size: 18),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0),
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
    );
  }
}
