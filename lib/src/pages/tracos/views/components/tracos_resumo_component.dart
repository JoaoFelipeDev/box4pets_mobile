// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/tracos/models/tracos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TracosResumoComponent extends StatelessWidget {
  final TracosModel tracos;
  final String id;
  final String resultado;

  const TracosResumoComponent({
    Key? key,
    required this.tracos,
    required this.id,
    required this.resultado,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tracos.traco,
                        style: GoogleFonts.dmSans(
                          color: AppColor.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.7,
                          height: 1.1,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 320.ms)
                          .slideY(begin: -0.05, end: 0),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          id.toUpperCase(),
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      )
                          .animate(delay: 60.ms)
                          .fadeIn(duration: 320.ms),
                      const SizedBox(height: 18),
                      _ResultBlock(
                        label: 'Resultado',
                        value: resultado.isEmpty ? '—' : resultado,
                        color: AppColor.secondary,
                        icon: Icons.flag_rounded,
                        highlighted: true,
                      )
                          .animate(delay: 120.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.05, end: 0),
                      if ((tracos.gene1 ?? '').isNotEmpty ||
                          (tracos.variante ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if ((tracos.gene1 ?? '').isNotEmpty)
                              Expanded(
                                child: _ResultBlock(
                                  label: 'Gene',
                                  value: tracos.gene1!,
                                  color: AppColor.primary,
                                  icon: Icons.science_outlined,
                                ),
                              ),
                            if ((tracos.gene1 ?? '').isNotEmpty &&
                                (tracos.variante ?? '').isNotEmpty)
                              const SizedBox(width: 10),
                            if ((tracos.variante ?? '').isNotEmpty)
                              Expanded(
                                child: _ResultBlock(
                                  label: 'Variante',
                                  value: tracos.variante!,
                                  color: const Color(0xFF8B5CF6),
                                  icon: Icons.bubble_chart_rounded,
                                ),
                              ),
                          ],
                        ).animate(delay: 160.ms).fadeIn(duration: 380.ms),
                      ],
                      const SizedBox(height: 18),
                      if ((tracos.sobre_traco ?? '').isNotEmpty)
                        _SectionCard(
                          icon: Icons.menu_book_rounded,
                          color: AppColor.primary,
                          title: 'Sobre o traço',
                          body: tracos.sobre_traco!,
                        )
                            .animate(delay: 200.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.05, end: 0),
                      if ((tracos.racas ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _SectionCard(
                          icon: Icons.pets_rounded,
                          color: AppColor.secondary,
                          title: 'Raças relacionadas',
                          body: tracos.racas!,
                        )
                            .animate(delay: 240.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.05, end: 0),
                      ],
                      if ((tracos.referencias ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _SectionCard(
                          icon: Icons.link_rounded,
                          color: const Color(0xFF8B5CF6),
                          title: 'Referências',
                          body: tracos.referencias!,
                        )
                            .animate(delay: 280.ms)
                            .fadeIn(duration: 380.ms)
                            .slideY(begin: 0.05, end: 0),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
}

class _ResultBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool highlighted;
  const _ResultBlock({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 14, vertical: highlighted ? 16 : 12),
      decoration: BoxDecoration(
        color: highlighted ? color : color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  color: highlighted ? Colors.white : color, size: 14),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: highlighted ? Colors.white : color,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: highlighted ? 6 : 4),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: highlighted ? Colors.white : color.withOpacity(0.95),
              fontSize: highlighted ? 18 : 14,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _SectionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: GoogleFonts.archivo(
              fontSize: 13.5,
              height: 1.6,
              color: AppColor.primary.withOpacity(0.78),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
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
