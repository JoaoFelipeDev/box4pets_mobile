import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/core/ui/widgets/shimmer.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:Box4Pets/src/pages/destaques/views/components/screen_expanded.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewMore extends StatefulWidget {
  final List<BlogModel> listBlog;
  final String title;
  const ViewMore({
    Key? key,
    required this.listBlog,
    required this.title,
  }) : super(key: key);

  @override
  State<ViewMore> createState() => _ViewMoreState();
}

class _ViewMoreState extends State<ViewMore> {
  static const int _pageSize = 8;
  late final ScrollController _scrollController;
  int _displayedCount = _pageSize;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _displayedCount =
        widget.listBlog.length < _pageSize ? widget.listBlog.length : _pageSize;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (_displayedCount >= widget.listBlog.length) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 280) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!mounted) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _displayedCount =
          (_displayedCount + _pageSize).clamp(0, widget.listBlog.length);
      _loadingMore = false;
    });
  }

  void _openItem(BuildContext context, BlogModel item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, __, ___) =>
            ScreenExpanded(blog: item, tag: 'viewmore-${item.id}'),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final shown = widget.listBlog.take(_displayedCount).toList();
    final hasMore = _displayedCount < widget.listBlog.length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, topInset + 64, 20, 4),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.dmSans(
                            color: AppColor.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -28 * 0.04,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.listBlog.length} ${widget.listBlog.length == 1 ? 'item' : 'itens'}',
                          style: GoogleFonts.archivo(
                            color: AppColor.primary.withOpacity(0.55),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 320.ms).slideY(
                        begin: -0.08, end: 0),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _GridCard(
                          item: shown[index],
                          onTap: () => _openItem(context, shown[index]),
                        )
                            .animate(delay: (30 * (index % _pageSize)).ms)
                            .fadeIn(duration: 280.ms)
                            .slideY(begin: 0.08, end: 0);
                      },
                      childCount: shown.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    child: Center(
                      child: hasMore
                          ? (_loadingMore
                              ? _LoadingDots()
                              : _LoadMoreButton(onTap: _loadMore))
                          : (widget.listBlog.length > _pageSize
                              ? Text(
                                  'Você viu tudo ✨',
                                  style: GoogleFonts.archivo(
                                    color: AppColor.primary.withOpacity(0.45),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: topInset + 12,
              left: 16,
              child: _GlassBackButton(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LoadMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Carregar mais',
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_downward_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (1 - (t - 0.5).abs() * 2).clamp(0.25, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primary.withOpacity(opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _GridCard extends StatelessWidget {
  final BlogModel item;
  final VoidCallback onTap;
  const _GridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = item.banner.isNotEmpty ? item.banner[0].url : null;
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'viewmore-${item.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: SmartNetworkImage(url: image),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          item.titulo,
                          style: GoogleFonts.dmSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColor.primary,
                            height: 1.2,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (item.subTitulo.isNotEmpty)
                          Expanded(
                            child: Text(
                              item.subTitulo,
                              style: GoogleFonts.archivo(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColor.primary.withOpacity(0.5),
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
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

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColor.primary, size: 16),
          ),
        ),
      ),
    );
  }
}
