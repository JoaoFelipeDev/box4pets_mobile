// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/http/endpoint_dio.dart';
import 'package:Box4Pets/src/pages/tracos/bloc/tracos_bloc.dart';
import 'package:Box4Pets/src/pages/tracos/models/tracos_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'components/tracos_resumo_component.dart';

class Tracos extends StatefulWidget {
  final String id;
  final String especie;
  final String box;
  final String subTitle;
  const Tracos({
    Key? key,
    required this.id,
    required this.especie,
    required this.box,
    required this.subTitle,
  }) : super(key: key);

  @override
  State<Tracos> createState() => _TracosState();
}

class _TracosState extends State<Tracos> {
  bool result = false;
  final http = EndpointDio();
  List<String> resultadoValor = [];
  late final TracosBloc _tracosBloc;

  static const List<Color> _palette = [
    Color(0xFF3F2873),
    Color(0xFF00A7C8),
    Color(0xFF8B5CF6),
    Color(0xFFFF7900),
    Color(0xFFE85D75),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFF22C55E),
    Color(0xFFEC4899),
    Color(0xFF7C3AED),
  ];

  Future<void> resultado(List<TracosModel> marcador) async {
    for (final element in marcador) {
      final Response<dynamic> response = await http.dio.get(
          '/app_resultado_saude_cao?filterByFormula=app_ativacao="${widget.box}"');

      if ((response.data['records'] as List).isNotEmpty) {
        final String? r =
            response.data['records'][0]['fields'][element.marcador];
        if (mounted) {
          setState(() => resultadoValor.add(r ?? ''));
        }
      }
    }
    if (mounted) setState(() => result = true);
  }

  @override
  void initState() {
    super.initState();
    _tracosBloc = TracosBloc()
      ..add(TracosGetEvent(id: widget.id, especie: widget.especie));
  }

  @override
  void dispose() {
    _tracosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TracosBloc, TracosState>(
      bloc: _tracosBloc,
      listener: (context, state) {
        if (state is TracosLoaded) resultado(state.tracos);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ParallaxBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocBuilder<TracosBloc, TracosState>(
                    bloc: _tracosBloc,
                    builder: (context, state) {
                      if (state is TracosLoaded) {
                        return _buildBody(state);
                      }
                      return const Box4PetsLoader();
                    },
                  ),
                ),
              ],
            ),
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

  Widget _buildBody(TracosLoaded state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.id,
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
          const SizedBox(height: 8),
          Text(
            widget.subTitle,
            style: GoogleFonts.archivo(
              color: AppColor.primary.withOpacity(0.65),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          )
              .animate(delay: 60.ms)
              .fadeIn(duration: 320.ms),
          const SizedBox(height: 22),
          for (int i = 0; i < state.tracos.length; i++) ...[
            _TracoItemRow(
              color: _palette[i % _palette.length],
              traco: state.tracos[i],
              resultado:
                  result && i < resultadoValor.length ? resultadoValor[i] : '',
              loading: !result,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TracosResumoComponent(
                    resultado: i < resultadoValor.length
                        ? resultadoValor[i]
                        : '',
                    tracos: state.tracos[i],
                    id: widget.id,
                  ),
                ),
              ),
            )
                .animate(delay: (40 * i).ms)
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.05, end: 0),
            if (i < state.tracos.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _TracoItemRow extends StatelessWidget {
  final Color color;
  final TracosModel traco;
  final String resultado;
  final bool loading;
  final VoidCallback onTap;
  const _TracoItemRow({
    required this.color,
    required this.traco,
    required this.resultado,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = resultado.isNotEmpty;
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
              child: Icon(Icons.science_outlined, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    traco.traco,
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      letterSpacing: -0.2,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loading
                        ? 'Carregando resultados, aguarde!'
                        : (hasResult ? resultado : '—'),
                    style: GoogleFonts.archivo(
                      color: loading
                          ? AppColor.secondary
                          : (hasResult
                              ? color
                              : AppColor.primary.withOpacity(0.4)),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
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
