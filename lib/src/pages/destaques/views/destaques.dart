import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/destaques/bloc/blog_bloc.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:Box4Pets/src/pages/destaques/views/components/screen_expanded.dart';
import 'package:Box4Pets/src/pages/destaques/views/components/view_more.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class Destaques extends StatefulWidget {
  const Destaques({Key? key}) : super(key: key);

  @override
  State<Destaques> createState() => _DestaquesState();
}

class _DestaquesState extends State<Destaques> {
  late final BlogBloc _blogBloc;
  late final PageController _featuredController;
  int _featuredIndex = 0;
  String _activeCategory = 'destaques';

  @override
  void initState() {
    super.initState();
    _blogBloc = BlogBloc()..add(BlogGetEvent());
    _featuredController =
        PageController(viewportFraction: 1.0, initialPage: 0);
  }

  @override
  void dispose() {
    _blogBloc.close();
    _featuredController.dispose();
    super.dispose();
  }

  void _openViewMore(List<BlogModel> items, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewMore(listBlog: items, title: title),
      ),
    );
  }

  void _openItem(BlogModel item) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 460),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) =>
            ScreenExpanded(blog: item, tag: 'destaque-${item.id}'),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<BlogBloc, BlogState>(
        bloc: _blogBloc,
        builder: (context, state) {
          if (state is BlogLoading || state is! BlogLoaded) {
            return const Box4PetsLoader();
          }

          final all = state.listBlog;
          final destaques = all.where((b) => b.destaques).toList();
          final novidades = all.where((b) => b.novidades).toList();
          final treinamentos = all.where((b) => b.treinamentos).toList();

          final showDestaques = _activeCategory == 'destaques';
          final showRacas =
              _activeCategory == 'destaques' || _activeCategory == 'racas';
          final showTracos =
              _activeCategory == 'destaques' || _activeCategory == 'tracos';
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 4, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildCategoryChips(destaques, novidades, treinamentos),
                const SizedBox(height: 22),
                if (showDestaques && destaques.isNotEmpty) ...[
                  _buildFeaturedCarousel(destaques),
                  const SizedBox(height: 26),
                ],
                if (showRacas && novidades.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Conheça as Raças',
                    onSeeAll: () => _openViewMore(novidades, 'Conheça as Raças'),
                  ),
                  const SizedBox(height: 12),
                  _activeCategory == 'racas'
                      ? _GridList(items: novidades, onTap: _openItem)
                      : _HorizontalList(items: novidades, onTap: _openItem),
                  const SizedBox(height: 24),
                ],
                if (showTracos && treinamentos.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Traços & Doenças',
                    onSeeAll: () => _openViewMore(
                        treinamentos, 'Traços & Doenças'),
                  ),
                  const SizedBox(height: 12),
                  _activeCategory == 'tracos'
                      ? _GridList(items: treinamentos, onTap: _openItem)
                      : _HorizontalList(items: treinamentos, onTap: _openItem),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descubra',
            style: GoogleFonts.dmSans(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -30 * 0.04,
              color: AppColor.primary,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Descubra raças, traços e cuidados pro seu pet',
            style: GoogleFonts.archivo(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColor.primary.withOpacity(0.55),
              height: 1.4,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildCategoryChips(
    List<BlogModel> destaques,
    List<BlogModel> novidades,
    List<BlogModel> treinamentos,
  ) {
    final cats = <_CategoryData>[
      _CategoryData(key: 'destaques', label: 'Destaques'),
      _CategoryData(key: 'racas', label: 'Raças'),
      _CategoryData(key: 'tracos', label: 'Traços'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          for (int i = 0; i < cats.length; i++) ...[
            _buildCatChip(cats[i]),
            if (i < cats.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    ).animate(delay: 80.ms).fadeIn(duration: 320.ms);
  }

  Widget _buildCatChip(_CategoryData c) {
    final selected = _activeCategory == c.key;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeCategory = c.key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColor.primary
                : AppColor.primary.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Text(
          c.label,
          style: TextStyle(
            color: selected ? Colors.white : AppColor.primary.withOpacity(0.7),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11.5,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<BlogModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _SectionHeader(title: 'Em destaque'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _featuredController,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            onPageChanged: (i) {
              HapticFeedback.lightImpact();
              setState(() => _featuredIndex = i);
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _featuredController,
                builder: (context, _) {
                  double delta = 0;
                  if (_featuredController.position.haveDimensions) {
                    delta = (_featuredController.page ?? 0) - index;
                  }
                  return _FeaturedCard(
                    item: items[index],
                    pageDelta: delta,
                    onTap: () => _openItem(items[index]),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final active = i == _featuredIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active
                      ? AppColor.primary
                      : AppColor.primary.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    ).animate(delay: 160.ms).fadeIn(duration: 380.ms);
  }
}

class _CategoryData {
  final String key;
  final String label;
  const _CategoryData({required this.key, required this.label});
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -18 * 0.035,
              color: AppColor.primary,
              height: 1.1,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver tudo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary.withOpacity(0.7),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColor.primary.withOpacity(0.7)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridList extends StatelessWidget {
  final List<BlogModel> items;
  final void Function(BlogModel) onTap;
  const _GridList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          return _HorizontalCard(
            item: items[index],
            onTap: () => onTap(items[index]),
          )
              .animate(delay: (40 * index).ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.08, end: 0);
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final BlogModel item;
  final VoidCallback onTap;
  final double pageDelta;
  const _FeaturedCard({
    required this.item,
    required this.onTap,
    this.pageDelta = 0,
  });

  @override
  Widget build(BuildContext context) {
    final image = item.banner.isNotEmpty ? item.banner[0].url : null;
    final width = MediaQuery.of(context).size.width;
    final clampedDelta = pageDelta.clamp(-1.0, 1.0);
    final absDelta = clampedDelta.abs();

    final parallaxX = -clampedDelta * width * 0.35;
    final contentOpacity = (1 - absDelta * 1.2).clamp(0.0, 1.0);
    final contentSlide = clampedDelta * 40;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: 'destaque-${item.id}',
          child: Material(
            type: MaterialType.transparency,
            child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ShimmerBox(borderRadius: BorderRadius.zero),
                if (image != null)
                  Transform.translate(
                    offset: Offset(parallaxX, 0),
                    child: OverflowBox(
                      maxWidth: width * 1.4,
                      maxHeight: double.infinity,
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        frameBuilder: (context, child, frame, wasSync) {
                          if (wasSync) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.68),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 22,
                  child: Transform.translate(
                    offset: Offset(contentSlide, 0),
                    child: Opacity(
                      opacity: contentOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 0.7,
                              ),
                            ),
                            child: const Text(
                              'DESTAQUE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.titulo,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              height: 1.08,
                              letterSpacing: -24 * 0.04,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subTitulo.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.subTitulo,
                              style: GoogleFonts.archivo(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<BlogModel> items;
  final void Function(BlogModel) onTap;
  const _HorizontalList({required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _HorizontalCard(
            item: items[index],
            onTap: () => onTap(items[index]),
          )
              .animate(delay: (60 * index).ms)
              .fadeIn(duration: 320.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _HorizontalCard extends StatelessWidget {
  final BlogModel item;
  final VoidCallback onTap;
  const _HorizontalCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final image = item.banner.isNotEmpty ? item.banner[0].url : null;
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'destaque-${item.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Container(
          width: 168,
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
                SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: SmartNetworkImage(url: image),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        Text(
                          item.subTitulo,
                          style: GoogleFonts.archivo(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColor.primary.withOpacity(0.5),
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
