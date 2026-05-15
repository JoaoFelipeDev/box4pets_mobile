// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/racas_model.dart';

class ViewRaca extends StatefulWidget {
  final RacasModel racaModel;
  const ViewRaca({Key? key, required this.racaModel}) : super(key: key);

  @override
  State<ViewRaca> createState() => _ViewRacaState();
}

class _ViewRacaState extends State<ViewRaca>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scroll;
  late final AnimationController _returnController;
  double _scrollOffset = 0;
  double _dragOffset = 0;
  double _dragStart = 0;
  bool _dismissing = false;

  static const double _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController()
      ..addListener(() {
        final next = _scroll.offset.clamp(0.0, double.infinity);
        if ((next - _scrollOffset).abs() > 0.5) {
          setState(() => _scrollOffset = next);
        }
      });
    _returnController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _dragOffset = _dragStart * (1 - _returnController.value);
        });
      });
  }

  void _onHeaderDragUpdate(DragUpdateDetails details) {
    if (_dismissing) return;
    final delta = details.delta.dy;
    if (delta <= 0 && _dragOffset <= 0) return;
    setState(() {
      _dragOffset = (_dragOffset + delta).clamp(0.0, 500.0);
    });
  }

  void _onHeaderDragEnd(DragEndDetails details) {
    if (_dismissing) return;
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (_dragOffset > _dismissThreshold || velocity > 800) {
      _dismissing = true;
      Navigator.pop(context);
    } else if (_dragOffset > 0) {
      _dragStart = _dragOffset;
      _returnController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _returnController.dispose();
    super.dispose();
  }

  void _openVoceSabia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                              Icons.lightbulb_outline_rounded,
                              color: Colors.white,
                              size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Você sabia?',
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                      child: Text(
                        widget.racaModel.voce_sabia,
                        style: GoogleFonts.archivo(
                          fontSize: 14.5,
                          height: 1.65,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.racaModel;
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.42;
    final imageUrl = r.url;
    final topInset = MediaQuery.of(context).padding.top;

    final dragProgress = (_dragOffset / 250).clamp(0.0, 1.0);
    final dismissScale = 1 - (dragProgress * 0.08);
    final dimOpacity = (1 - dragProgress) * 0.30;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(dimOpacity),
      body: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Transform.scale(
          scale: dismissScale,
          alignment: Alignment.topCenter,
          child: ParallaxBackground(
        child: Stack(
          children: [
            Positioned(
              top: -_scrollOffset * 0.4,
              left: 0,
              right: 0,
              height: headerHeight +
                  (_scrollOffset * 0.15).clamp(0.0, 80.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: imageUrl ?? 'race-${r.id}-${r.raca}',
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/cachorro1_solto 1.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          )
                        : Image.asset(
                            'assets/images/cachorro1_solto 1.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                  ),
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 50,
                    child: Material(
                      type: MaterialType.transparency,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.raca,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              height: 1.05,
                              letterSpacing: -28 * 0.04,
                              decoration: TextDecoration.none,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          if (r.regiao_origem.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.public_rounded,
                                    size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  r.regiao_origem,
                                  style: GoogleFonts.archivo(
                                    color:
                                        Colors.white.withOpacity(0.92),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(height: headerHeight - 40),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF8FF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 14),
                        _buildStatsGrid(r)
                            .animate(delay: 120.ms)
                            .fadeIn(duration: 380.ms),
                        if (r.descricao_raca != null &&
                            r.descricao_raca!.isNotEmpty) ...[
                          const SizedBox(height: 22),
                          _SectionCard(
                            icon: Icons.menu_book_rounded,
                            iconColor: AppColor.primary,
                            title: 'Descrição da raça',
                            body: r.descricao_raca!,
                          )
                              .animate(delay: 160.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                        if (r.origem_raca != null &&
                            r.origem_raca!.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SectionCard(
                            icon: Icons.history_rounded,
                            iconColor: AppColor.secondary,
                            title: 'Origem da raça',
                            body: r.origem_raca!,
                          )
                              .animate(delay: 200.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                        if (r.principais_caracteristicas.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SectionCard(
                            icon: Icons.stars_rounded,
                            iconColor: AppColor.orange,
                            title: 'Principais características',
                            body: r.principais_caracteristicas,
                          )
                              .animate(delay: 240.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                        if (r.pelagem.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SectionCard(
                            icon: Icons.brush_rounded,
                            iconColor: AppColor.primary,
                            title: 'Pelagem',
                            body: r.pelagem,
                          )
                              .animate(delay: 280.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                        if (r.cuidados_gerais.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SectionCard(
                            icon: Icons.favorite_rounded,
                            iconColor: const Color(0xFFE85D75),
                            title: 'Cuidados gerais',
                            body: r.cuidados_gerais,
                          )
                              .animate(delay: 320.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                        if (r.voce_sabia.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _openVoceSabia();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColor.orange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.orange.withOpacity(0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lightbulb_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Você sabia?',
                                          style: GoogleFonts.dmSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Curiosidades sobre essa raça',
                                          style: GoogleFonts.archivo(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate(delay: 360.ms)
                              .fadeIn(duration: 380.ms)
                              .slideY(begin: 0.05, end: 0),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight - 40,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: _onHeaderDragUpdate,
                onVerticalDragEnd: _onHeaderDragEnd,
              ),
            ),
            Positioned(
              top: topInset + 12,
              left: 16,
              child: _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(RacasModel r) {
    final stats = <_StatData>[
      if (r.altura.isNotEmpty)
        _StatData(
            icon: FontAwesomeIcons.ruler,
            label: 'Altura',
            value: r.altura),
      if (r.peso.isNotEmpty)
        _StatData(
            icon: FontAwesomeIcons.weightHanging,
            label: 'Peso',
            value: r.peso),
      if (r.expectativa_de_vida.isNotEmpty)
        _StatData(
            icon: FontAwesomeIcons.heartPulse,
            label: 'Expectativa',
            value: r.expectativa_de_vida),
      if (r.popularidade.isNotEmpty)
        _StatData(
            icon: FontAwesomeIcons.star,
            label: 'Popularidade',
            value: r.popularidade),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (context, i) => _StatTile(data: stats[i]),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatTile extends StatelessWidget {
  final _StatData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(
                data.icon,
                color: AppColor.primary,
                size: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    color: AppColor.primary.withOpacity(0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: -0.2,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _SectionCard({
    required this.icon,
    required this.iconColor,
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
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
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
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
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
