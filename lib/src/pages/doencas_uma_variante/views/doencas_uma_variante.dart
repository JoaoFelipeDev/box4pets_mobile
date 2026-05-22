// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/bloc/doencas_uma_variante_bloc.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/views/components/resumo_doenca_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DoencasUmaVariante extends StatefulWidget {
  final List<String> id;
  final String title;
  final String especie;
  final String box;
  const DoencasUmaVariante({
    Key? key,
    required this.id,
    required this.title,
    required this.especie,
    required this.box,
  }) : super(key: key);

  @override
  State<DoencasUmaVariante> createState() => _DoencasUmaVarianteState();
}

class _DoencasUmaVarianteState extends State<DoencasUmaVariante> {
  late final DoencasUmaVarianteBloc _doencasUmaVarianteBloc;

  static const List<Color> _palette = [
    Color(0xFF3F2873),
    Color(0xFF00A7C8),
    Color(0xFFFF7900),
    Color(0xFF8B5CF6),
    Color(0xFFE85D75),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF22C55E),
    Color(0xFFEC4899),
    Color(0xFF7C3AED),
  ];

  @override
  void initState() {
    super.initState();
    _doencasUmaVarianteBloc = DoencasUmaVarianteBloc()
      ..add(DoencasUmaVarianteGetEvent(
          id: widget.id, especie: widget.especie));
  }

  @override
  void dispose() {
    _doencasUmaVarianteBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                      height: 1.1,
                    ),
                  ).animate().fadeIn(duration: 320.ms).slideY(
                      begin: -0.05, end: 0),
                ),
              ),
              Expanded(
                child: BlocBuilder<DoencasUmaVarianteBloc,
                    DoencasUmaVarianteState>(
                  bloc: _doencasUmaVarianteBloc,
                  builder: (context, state) {
                    if (state is DoencasUmaVarianteLoaded) {
                      if (state.categorias.isEmpty) {
                        return _buildEmpty();
                      }
                      return _buildList(state);
                    } else if (state is DoencasUmaVarianteLoading) {
                      final progress = state.total > 0
                          ? (state.current / state.total).clamp(0.0, 1.0)
                          : 0.0;
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Box4PetsLoader(inline: true),
                              const SizedBox(height: 12),
                              Text(
                                state.total > 0
                                    ? 'Carregando · ${(progress * 100).round()}%'
                                    : 'Carregando...',
                                style: GoogleFonts.dmSans(
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (state.total > 0) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    width: 220,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      backgroundColor: AppColor.primary
                                          .withOpacity(0.12),
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppColor.primary),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${state.current} de ${state.total} doenças analisadas',
                                  style: GoogleFonts.archivo(
                                    color: AppColor.primary.withOpacity(0.55),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          SvgPicture.asset(
            'assets/logoB4p.svg',
            height: 26,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded,
                  color: AppColor.primary, size: 30),
            ),
            const SizedBox(height: 14),
            Text(
              'Nenhuma variante identificada',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: AppColor.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(DoencasUmaVarianteLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: state.categorias.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = state.categorias[index];
        if (cat == 'Nenhuma Variante Identificada') {
          return _buildEmpty();
        }
        final color = _palette[index % _palette.length];
        return _CategoryRow(
          color: color,
          title: cat,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResumoDoencaComponent(
                doenca: state.doenca
                    .where((e) => e.categoria == cat)
                    .toList(),
                categoria: cat,
                box: widget.box,
                especies: widget.especie,
              ),
            ),
          ),
        )
            .animate(delay: (40 * index).ms)
            .fadeIn(duration: 280.ms)
            .slideY(begin: 0.05, end: 0);
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onTap;
  const _CategoryRow({
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.medical_services_outlined,
                  color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColor.primary.withOpacity(0.4), size: 22),
          ],
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
