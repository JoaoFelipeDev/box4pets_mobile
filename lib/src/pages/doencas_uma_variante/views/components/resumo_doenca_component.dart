// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/doencas_uma_variante/models/app_lista_doencas_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'doenca_completa_component.dart';

class ResumoDoencaComponent extends StatefulWidget {
  final List<AppListaDoencasModel> doenca;
  final String box;
  final String categoria;
  final String especies;

  const ResumoDoencaComponent({
    Key? key,
    required this.doenca,
    required this.box,
    required this.categoria,
    required this.especies,
  }) : super(key: key);

  @override
  State<ResumoDoencaComponent> createState() => _ResumoDoencaComponentState();
}

class _ResumoDoencaComponentState extends State<ResumoDoencaComponent> {
  final http = EndpointDio();
  List<String> resultadoValor = [];
  bool result = false;

  static const List<Color> _palette = [
    Color(0xFFE85D75),
    Color(0xFFFF7900),
    Color(0xFF8B5CF6),
    Color(0xFF3F2873),
    Color(0xFF00A7C8),
    Color(0xFF7C3AED),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  Future<void> resultado(List<AppListaDoencasModel> marcador) async {
    for (final element in marcador) {
      final Response<dynamic> response = await http.dio.get(
          '/app_resultado_saude_cao?filterByFormula=app_ativacao="${widget.box}"');

      if ((response.data['records'] as List).isNotEmpty) {
        final String? r =
            response.data['records'][0]['fields'][element.marcador];
        if (mounted) setState(() => resultadoValor.add(r ?? ''));
      }
    }
    if (mounted) setState(() => result = true);
  }

  @override
  void initState() {
    super.initState();
    resultado(widget.doenca);
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
                    widget.categoria,
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
                ),
              ),
              Expanded(
                child: result
                    ? _buildList()
                    : const Box4PetsLoader(),
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

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: widget.doenca.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = widget.doenca[index];
        final r = index < resultadoValor.length ? resultadoValor[index] : '';
        final color = _palette[index % _palette.length];
        return _DoencaRow(
          color: color,
          title: d.doenca,
          gene: d.gene,
          resultado: r,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoencaCompletaComponent(
                doenca: d,
                resultado: r,
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

class _DoencaRow extends StatelessWidget {
  final Color color;
  final String title;
  final String gene;
  final String resultado;
  final VoidCallback onTap;
  const _DoencaRow({
    required this.color,
    required this.title,
    required this.gene,
    required this.resultado,
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
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.biotech_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          gene,
                          style: GoogleFonts.archivo(
                            color: AppColor.primary.withOpacity(0.75),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          resultado.isEmpty ? '—' : resultado,
                          style: GoogleFonts.archivo(
                            color: color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
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
