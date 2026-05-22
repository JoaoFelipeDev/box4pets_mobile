// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:Box4Pets/src/pages/teste_racas/bloc/teste_racas_bloc.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/components/gerar_pdf_racas.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/components/view_raca.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:fl_chart/fl_chart.dart' show FlTouchEvent;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';

import '../models/app_resultado_raca_model.dart';
import '../models/racas_model.dart';

class TesteRaca extends StatefulWidget {
  final String id;
  final String name;
  final AppAtivacaoModel ativacao;
  const TesteRaca({
    Key? key,
    required this.id,
    required this.name,
    required this.ativacao,
  }) : super(key: key);

  @override
  State<TesteRaca> createState() => _TesteRacaState();
}

class _TesteRacaState extends State<TesteRaca> {
  Uint8List? _imageFile;
  final ScreenshotController screenshotController = ScreenshotController();
  late final TesteRacasBloc _testeRacasBloc;
  int _touchedIndex = -1;

  static const List<Color> _palette = [
    Color(0xFF3F2873),
    Color(0xFF00A7C8),
    Color(0xFFFF7900),
    Color(0xFF8B5CF6),
    Color(0xFFE85D75),
    Color(0xFF06B6D4),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
    Color(0xFFEC4899),
    Color(0xFF7C3AED),
    Color(0xFF22C55E),
    Color(0xFFEAB308),
  ];

  final List<_ExplainPage> _explainPages = [
    _ExplainPage(
      icon: Icons.science_outlined,
      title: 'Como funciona',
      body:
          'O teste genético analisa o DNA do seu cão e revela as raças que contribuíram pra composição genética dele. É uma janela direta pra árvore genealógica do seu pet.',
    ),
    _ExplainPage(
      icon: Icons.family_restroom_rounded,
      title: 'Raças ascendentes',
      body:
          'O teste identifica raças que estiveram presentes nos ancestrais há mais de 3 gerações. Por serem formadoras, têm influência mínima nas características físicas e no comportamento atual.\n\nMesmo cães de raça pura podem apresentar raças ascendentes nesse mapeamento.',
    ),
    _ExplainPage(
      icon: Icons.help_outline_rounded,
      title: 'Raças indeterminadas',
      body:
          'O sequenciamento genético canino no Brasil ainda está evoluindo. É natural encontrar resultados marcados como "indeterminada" — reflexo da grande diversidade das misturas brasileiras.\n\nIsso não é uma limitação do teste: é a riqueza genética dos nossos cães.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _testeRacasBloc = TesteRacasBloc()
      ..add(TesteRacasGetAppResultadoRacasEvent(id: widget.id));
  }

  void _openExplain() {
    final controller = CarouselSliderController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        int currentPage = 0;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                      0, 10, 0, 20 + MediaQuery.of(ctx).padding.bottom),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 6),
                        child: Center(
                          child: Text(
                            'Entenda o resultado',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.dmSans(
                              color: AppColor.secondary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                      ),
                      CarouselSlider.builder(
                        carouselController: controller,
                        options: CarouselOptions(
                          height: 300,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          enableInfiniteScroll: false,
                          onPageChanged: (i, _) {
                            setSheetState(() => currentPage = i);
                          },
                        ),
                        itemCount: _explainPages.length,
                        itemBuilder: (_, i, __) {
                          final p = _explainPages[i];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(16),
                                    ),
                                    child: Icon(p.icon,
                                        color: AppColor.secondary,
                                        size: 26),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    p.title,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p.body,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.archivo(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: Colors.white.withOpacity(0.92),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            List.generate(_explainPages.length, (i) {
                          final active = i == currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: active ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColor.secondary
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            if (currentPage > 0) ...[
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    side: BorderSide(
                                        color:
                                            Colors.white.withOpacity(0.4)),
                                  ),
                                  onPressed: () => controller.previousPage(
                                      duration: const Duration(
                                          milliseconds: 280),
                                      curve: Curves.easeOut),
                                  child: const Text(
                                    'Anterior',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.secondary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (currentPage ==
                                      _explainPages.length - 1) {
                                    Navigator.pop(ctx);
                                  } else {
                                    controller.nextPage(
                                        duration: const Duration(
                                            milliseconds: 280),
                                        curve: Curves.easeOut);
                                  }
                                },
                                child: Text(
                                  currentPage == _explainPages.length - 1
                                      ? 'Entendi'
                                      : 'Próximo',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _testeRacasBloc.close();
    super.dispose();
  }

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    try {
      final image = await screenshotController.capture(
          delay: const Duration(milliseconds: 10));
      if (image != null) {
        setState(() => _imageFile = image);
        if (mounted) {
          reportViwRacas(context,
              image: _imageFile!, ativacao: widget.ativacao);
        }
      }
    } catch (_) {}
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
              Expanded(
                child: BlocBuilder<TesteRacasBloc, TesteRacasState>(
                  bloc: _testeRacasBloc,
                  builder: (context, state) {
                    if (state is TesteRacasLoading || state is! TesteRacasLoaded) {
                      return const Box4PetsLoader();
                    }
                    return _buildBody(state);
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
          _GlassIconButton(
            icon: Icons.ios_share_rounded,
            onTap: _share,
            background: AppColor.orange,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TesteRacasLoaded state) {
    final list = [...state.resuldado]
      ..sort((a, b) => b.porcent.compareTo(a.porcent));

    final listRacas = <RacasModel>[];
    for (final porcent in list) {
      final match = state.racas
          .where((r) => r.raca == porcent.racas)
          .toList();
      if (match.isEmpty) continue;
      final r = match.first;
      listRacas.add(RacasModel(
        id: r.id,
        raca: r.raca,
        regiao_origem: r.regiao_origem,
        origem_raca: r.origem_raca,
        peso: r.peso,
        altura: r.altura,
        expectativa_de_vida: r.expectativa_de_vida,
        pelagem: r.pelagem,
        principais_caracteristicas: r.principais_caracteristicas,
        cuidados_gerais: r.cuidados_gerais,
        voce_sabia: r.voce_sabia,
        popularidade: r.popularidade,
        health: r.health,
        porcent: porcent.porcent,
        descricao_raca: r.descricao_raca,
        url: r.url,
      ));
    }

    final dataMap = <String, double>{};
    for (final e in list) {
      final pct = (e.porcent * 100).round();
      dataMap['${e.racas} · $pct%'] = pct.toDouble();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: _buildPetCard(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _buildSectionTitle(
              'Composição genética',
              'Com base no DNA do seu pet',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildChartCard(dataMap, listRacas),
          ),
          const SizedBox(height: 22),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildSectionTitle(
              'Raças detectadas',
              '${listRacas.length} ${listRacas.length == 1 ? 'raça' : 'raças'}',
            ),
          ),
          _buildRaceList(listRacas),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildExplainButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard() {
    final pet = widget.ativacao;
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE7DDF8),
                image: pet.url != null
                    ? DecorationImage(
                        image: NetworkImage(pet.url!), fit: BoxFit.cover)
                    : null,
              ),
              child: pet.url == null
                  ? Icon(Icons.pets, color: AppColor.primary, size: 24)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.name,
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [pet.raca, pet.sexo]
                        .where((s) => s.isNotEmpty)
                        .join(' · '),
                    style: GoogleFonts.archivo(
                      color: AppColor.primary.withOpacity(0.55),
                      fontWeight: FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'TESTE DE RAÇA',
                style: TextStyle(
                  color: AppColor.secondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            color: AppColor.primary,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.archivo(
            color: AppColor.primary.withOpacity(0.55),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(
      Map<String, double> dataMap, List<RacasModel> races) {
    if (races.isEmpty) return const SizedBox.shrink();
    final chartSize = MediaQuery.of(context).size.width * 0.74;
    final activeIndex =
        _touchedIndex >= 0 && _touchedIndex < races.length ? _touchedIndex : 0;
    final activeRace = races[activeIndex];
    final activePct = ((activeRace.porcent ?? 0) * 100).round();

    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Screenshot(
          controller: screenshotController,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 30, 8, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: TweenAnimationBuilder<double>(
                    key: const ValueKey('chart-entrance'),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1300),
                    curve: Curves.easeInOutCubic,
                    builder: (context, progress, _) {
                      return SizedBox(
                        height: chartSize,
                        width: chartSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipPath(
                              clipper: _SweepClipper(progress),
                              child: fl.PieChart(
                                fl.PieChartData(
                                  startDegreeOffset: -90,
                                  sectionsSpace: 3,
                                  centerSpaceRadius: chartSize * 0.28,
                                  sections: [
                                    for (int i = 0; i < races.length; i++)
                                      fl.PieChartSectionData(
                                        value:
                                            ((races[i].porcent ?? 0) * 100),
                                        color: _palette[i % _palette.length],
                                        radius: i == _touchedIndex
                                            ? chartSize * 0.21
                                            : chartSize * 0.16,
                                        showTitle: progress > 0.85,
                                        title:
                                            '${((races[i].porcent ?? 0) * 100).round()}%',
                                        titlePositionPercentageOffset: 0.6,
                                        titleStyle: GoogleFonts.dmSans(
                                          fontSize:
                                              i == _touchedIndex ? 13 : 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          shadows: const [
                                            Shadow(
                                                color: Colors.black38,
                                                blurRadius: 4,
                                                offset: Offset(0, 1)),
                                          ],
                                        ),
                                      ),
                                  ],
                                  pieTouchData: fl.PieTouchData(
                                    touchCallback: (FlTouchEvent event,
                                        pieTouchResponse) {
                                      if (progress < 0.95) return;
                                      setState(() {
                                        if (!event
                                                .isInterestedForInteractions ||
                                            pieTouchResponse == null ||
                                            pieTouchResponse.touchedSection ==
                                                null) {
                                          _touchedIndex = -1;
                                          return;
                                        }
                                        _touchedIndex = pieTouchResponse
                                            .touchedSection!
                                            .touchedSectionIndex;
                                        HapticFeedback.selectionClick();
                                      });
                                    },
                                  ),
                                ),
                                duration: const Duration(milliseconds: 220),
                              ),
                            ),
                            IgnorePointer(
                              child: Opacity(
                                opacity: progress,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 6),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _palette[
                                            activeIndex % _palette.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Text(
                                      '${(activePct * progress).round()}%',
                                      style: GoogleFonts.dmSans(
                                        color: AppColor.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 38,
                                        height: 1.0,
                                        letterSpacing: -38 * 0.04,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: chartSize * 0.5),
                                      child: Text(
                                        activeRace.raca,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.archivo(
                                          color: AppColor.primary
                                              .withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11.5,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                for (int i = 0; i < races.length; i++) ...[
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _touchedIndex = _touchedIndex == i ? -1 : i;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: i == _touchedIndex
                            ? _palette[i % _palette.length].withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _ChartLegendRow(
                        color: _palette[i % _palette.length],
                        name: races[i].raca,
                        pct: ((races[i].porcent ?? 0) * 100).round(),
                      ),
                    ),
                  ),
                  if (i < races.length - 1) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: 80.ms).fadeIn(duration: 380.ms);
  }

  Widget _buildRaceList(List<RacasModel> listRacas) {
    return SizedBox(
      height: 248,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: listRacas.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final r = listRacas[index];
          final color = _palette[index % _palette.length];
          return _RaceCard(
            race: r,
            color: color,
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.transparent,
                transitionDuration: const Duration(milliseconds: 460),
                reverseTransitionDuration:
                    const Duration(milliseconds: 320),
                pageBuilder: (_, __, ___) => ViewRaca(racaModel: r),
                transitionsBuilder: (_, animation, __, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuart,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0)
                          .animate(curved),
                      child: child,
                    ),
                  );
                },
              ),
            ),
          )
              .animate(delay: (60 * index).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.08, end: 0);
        },
      ),
    );
  }

  Widget _buildExplainButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _openExplain();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Entender o resultado',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartLegendRow extends StatelessWidget {
  final Color color;
  final String name;
  final int pct;
  const _ChartLegendRow({
    required this.color,
    required this.name,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4, right: 8),
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.archivo(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColor.primary.withOpacity(0.85),
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$pct%',
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: AppColor.primary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _ExplainPage {
  final IconData icon;
  final String title;
  final String body;
  const _ExplainPage({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _RaceCard extends StatelessWidget {
  final RacasModel race;
  final Color color;
  final VoidCallback onTap;
  const _RaceCard({
    required this.race,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = ((race.porcent ?? 0) * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 152,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag:
                      race.url ?? 'race-${race.id}-${race.raca}',
                  child: Container(
                    width: 152,
                    height: 152,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                      image: race.url != null
                          ? DecorationImage(
                              image: NetworkImage(race.url!),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : const DecorationImage(
                              image: AssetImage(
                                  'assets/images/cachorro1_solto 1.png'),
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.25),
                          blurRadius: 18,
                          spreadRadius: -4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pct%',
                          style: GoogleFonts.dmSans(
                            color: color,
                            fontWeight: FontWeight.w800,
                            fontSize: 25,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, right: 6),
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    race.raca,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Conhecer mais',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded,
                      size: 11, color: color),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SweepClipper extends CustomClipper<Path> {
  final double progress;
  _SweepClipper(this.progress);

  @override
  Path getClip(Size size) {
    if (progress >= 0.999) {
      return Path()..addRect(Offset.zero & size);
    }
    if (progress <= 0) return Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide;
    final sweepAngle = 2 * math.pi * progress;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_SweepClipper old) => old.progress != progress;
}

class _SharePill extends StatelessWidget {
  final VoidCallback onTap;
  const _SharePill({required this.onTap});

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
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.ios_share_rounded,
                    color: AppColor.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Compartilhar',
                  style: GoogleFonts.dmSans(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
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

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? background;
  final Color? iconColor;
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.background,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = background ?? Colors.white.withOpacity(0.7);
    final ic = iconColor ?? AppColor.primary;
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
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: background != null
                    ? background!.withOpacity(0.7)
                    : Colors.white.withOpacity(0.6),
                width: 1,
              ),
              boxShadow: background != null
                  ? [
                      BoxShadow(
                        color: background!.withOpacity(0.32),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: ic, size: 16),
          ),
        ),
      ),
    );
  }
}
