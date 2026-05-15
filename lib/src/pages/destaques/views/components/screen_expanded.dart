import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/shimmer.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenExpanded extends StatefulWidget {
  final BlogModel blog;
  final String tag;
  const ScreenExpanded({
    Key? key,
    required this.blog,
    required this.tag,
  }) : super(key: key);

  @override
  State<ScreenExpanded> createState() => _ScreenExpandedState();
}

class _ScreenExpandedState extends State<ScreenExpanded>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _returnController;
  double _scrollOffset = 0;
  double _dragOffset = 0;
  double _dragStart = 0;
  bool _dismissing = false;

  static const double _dismissThreshold = 120.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _returnController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    )..addListener(() {
        if (!mounted) return;
        setState(() {
          _dragOffset = _dragStart * (1 - _returnController.value);
        });
      });
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  void _onScroll() {
    if (!mounted) return;
    final next = _scrollController.offset.clamp(0.0, double.infinity);
    if ((next - _scrollOffset).abs() > 0.5) {
      setState(() => _scrollOffset = next);
    }
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _returnController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.46;
    final imageUrl = widget.blog.banner.isNotEmpty
        ? widget.blog.banner[0].url
        : null;
    final topInset = MediaQuery.of(context).padding.top;

    final dragProgress = (_dragOffset / 250).clamp(0.0, 1.0);
    final dismissScale = 1 - (dragProgress * 0.08);
    final dimOpacity = (1 - dragProgress) * 0.35;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(dimOpacity),
      extendBodyBehindAppBar: true,
      body: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Transform.scale(
          scale: dismissScale,
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              Positioned(
                top: -_scrollOffset * 0.45,
                left: 0,
                right: 0,
                height: headerHeight + (_scrollOffset * 0.15).clamp(0.0, 80.0),
                child: Hero(
                  tag: widget.tag,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartNetworkImage(url: imageUrl),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.25),
                              Colors.transparent,
                              Colors.black.withOpacity(0.35),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
          CustomScrollView(
            controller: _scrollController,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 60),
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
                      const SizedBox(height: 24),
                      _buildChips()
                          .animate()
                          .fadeIn(duration: 320.ms)
                          .slideY(begin: 0.15, end: 0),
                      const SizedBox(height: 14),
                      Text(
                        widget.blog.titulo,
                        style: GoogleFonts.dmSans(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          letterSpacing: -30 * 0.04,
                          color: const Color(0xFF111111),
                        ),
                      )
                          .animate(delay: 60.ms)
                          .fadeIn(duration: 380.ms)
                          .slideY(begin: 0.15, end: 0),
                      if (widget.blog.subTitulo.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.blog.subTitulo,
                          style: GoogleFonts.archivo(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.55),
                            height: 1.5,
                          ),
                        )
                            .animate(delay: 120.ms)
                            .fadeIn(duration: 380.ms),
                      ],
                      const SizedBox(height: 22),
                      _buildAuthorRow()
                          .animate(delay: 180.ms)
                          .fadeIn(duration: 380.ms),
                      const SizedBox(height: 20),
                      Divider(
                        color: Colors.black.withOpacity(0.06),
                        height: 1,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        widget.blog.conteudo,
                        style: GoogleFonts.archivo(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black.withOpacity(0.78),
                          fontWeight: FontWeight.w400,
                        ),
                      )
                          .animate(delay: 240.ms)
                          .fadeIn(duration: 420.ms),
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
    );
  }

  Widget _buildChips() {
    final chips = <Widget>[];
    if (widget.blog.destaques) {
      chips.add(_Chip(label: 'Destaque', color: AppColor.primary));
    }
    if (widget.blog.treinamentos) {
      chips.add(_Chip(label: 'Traços & Doenças', color: AppColor.secondary));
    }
    if (widget.blog.novidades) {
      chips.add(_Chip(label: 'Raças', color: AppColor.orange));
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

  String _formatDateBR(String input) {
    if (input.isEmpty) return '';
    try {
      final dt = DateTime.parse(input);
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year.toString();
      return '$d/$m/$y';
    } catch (_) {
      return input.length > 10 ? input.substring(0, 10) : input;
    }
  }

  Widget _buildAuthorRow() {
    final hasAuthor = widget.blog.autor.isNotEmpty;
    final dateBR = _formatDateBR(widget.blog.dataCriacao);
    final hasDate = dateBR.isNotEmpty;
    final readingMin =
        (widget.blog.conteudo.length / 900).ceil().clamp(1, 30);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasAuthor || hasDate) ...[
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColor.primary.withOpacity(0.12),
            child: Icon(
              hasAuthor
                  ? Icons.person_rounded
                  : Icons.calendar_today_rounded,
              color: AppColor.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasAuthor)
                  Text(
                    widget.blog.autor,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                if (hasDate)
                  Text(
                    hasAuthor ? dateBR : 'Publicado em $dateBR',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.black.withOpacity(0.45),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ] else
          const Spacer(),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_rounded,
                  size: 11, color: AppColor.primary),
              const SizedBox(width: 4),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: AppColor.primary.withOpacity(0.75),
                  ),
                  children: [
                    const TextSpan(text: 'Tempo de Leitura: '),
                    TextSpan(
                      text: '$readingMin min',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.1,
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
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 18, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
