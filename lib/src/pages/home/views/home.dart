import 'dart:io';
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/destaques/models/blog_model.dart';
import 'package:Box4Pets/src/pages/home/bloc/app_ativacao_bloc.dart';
import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:Box4Pets/src/pages/teste_racas/views/teste_raca.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/tracos_doencas.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/shimmer.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../destaques/views/components/screen_expanded.dart';
import '../../profile_dog/views/profile_dog.dart';
import '../repositories/app_ativacao_repository.dart';

enum _HomeTab { aguardandoSwab, emAnalise, resultados }

class _PetActionData {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _PetActionData({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(borderRadius),
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

class Home extends StatefulWidget {
  final VoidCallback? onProfileRequested;
  const Home({Key? key, this.onProfileRequested}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final AppAtivacaoBloc _appAtivacaoBloc;
  final appAtivacaoRepository = AppAtivacaoRepository();
  final box = GetStorage();

  _HomeTab _selectedTab = _HomeTab.resultados;
  String _searchQuery = '';
  int _carouselIndex = 0;
  int _selectedPetIndex = 0;
  String? _localPhotoPath;
  AppAtivacaoLoaded? _lastLoaded;
  late final PageController _carouselController;
  late final ScrollController _petStripController;

  @override
  void initState() {
    super.initState();
    _appAtivacaoBloc = AppAtivacaoBloc()..add(AppAtivacaoGetEvent());
    _carouselController = PageController(initialPage: 0);
    _petStripController = ScrollController();

    final savedPhoto = box.read('profile_photo_path');
    if (savedPhoto is String &&
        savedPhoto.isNotEmpty &&
        File(savedPhoto).existsSync()) {
      _localPhotoPath = savedPhoto;
    }

    Future.delayed(Duration.zero, _checkVersion);
  }

  @override
  void dispose() {
    _appAtivacaoBloc.close();
    _carouselController.dispose();
    _petStripController.dispose();
    super.dispose();
  }

  Future<String> _getStoragePath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory!.path;
  }

  Future<void> _downloadPdf(String url, String name) async {
    await Permission.storage.request();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Download iniciado'),
        backgroundColor: AppColor.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    final savedDir = await _getStoragePath();
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savedDir,
      fileName: name,
      showNotification: true,
      openFileFromNotification: true,
    );
    if (taskId != null) {
      await OpenFile.open('$savedDir/$name');
    }
  }

  void _openDownloadSheet(List urls, List names) {
    if (urls.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 10, 20, 20 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
              'Outros exames',
              style: GoogleFonts.dmSans(
                color: AppColor.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escolha o PDF que deseja baixar',
              style: GoogleFonts.archivo(
                color: AppColor.primary.withOpacity(0.55),
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < urls.length; i++)
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _downloadPdf(urls[i].toString(), names[i].toString());
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EEFC),
                    borderRadius: BorderRadius.circular(14),
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
                        child: Icon(Icons.description_rounded,
                            color: AppColor.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          names[i].toString(),
                          style: GoogleFonts.archivo(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Icon(Icons.download_rounded,
                          color: AppColor.primary, size: 18),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _centerSelectedPet(int index) {
    if (!_petStripController.hasClients) return;
    const itemWidth = 56.0 + 14.0;
    final viewportW = _petStripController.position.viewportDimension;
    final target = (index * itemWidth + itemWidth / 2) - viewportW / 2;
    final clamped = target.clamp(
      _petStripController.position.minScrollExtent,
      _petStripController.position.maxScrollExtent,
    );
    _petStripController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _checkVersion() async {
    try {
      final Response<dynamic> response = await appAtivacaoRepository.getVersion();
      final String version = response.data['records'][0]['fields']['Name'];
      if (box.read('version') != version) _openModalVersion();
    } catch (_) {}
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openModalVersion() {
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Atualização disponível'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
              'Uma atualização recente do Box4Pets está disponível agora!'),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Deixar para depois'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              if (Theme.of(context).platform == TargetPlatform.iOS) {
                _launchURL(
                    'https://apps.apple.com/us/app/box4pets/id6467569454?platform=iphone');
              } else {
                _launchURL(
                    'https://play.google.com/store/apps/details?id=br.com.box4pets.box_4_pets&pli=1');
              }
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  void _selectTab(_HomeTab tab) {
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppAtivacaoBloc, AppAtivacaoState>(
        bloc: _appAtivacaoBloc,
        listener: (context, state) {
          if (state is AppAtivacaoLoaded) {
            _lastLoaded = state;
          } else if (state is AppDownloadPDF) {
            _openDownloadSheet(state.downloadPDFModel.url,
                state.downloadPDFModel.name);
            _appAtivacaoBloc.add(AppAtivacaoGetEvent());
          }
        },
        builder: (context, state) {
          final loaded = state is AppAtivacaoLoaded ? state : _lastLoaded;
          final List<BlogModel> allBlog = loaded?.blog ?? const [];
          final sorted = [...allBlog]
            ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
          final List<BlogModel> blog = sorted.take(6).toList();
          final List<AppAtivacaoModel> realPets =
              loaded?.appAtivacao ?? const [];
          final List<AppAtivacaoModel> allPets = realPets;
          final q = _searchQuery.trim().toLowerCase();
          final pets = allPets.where((p) {
            final s = (p.status_aplicativo ?? '').toLowerCase();
            final isLiberado = s.contains('liberado');
            final isSwab = s.contains('swab');
            bool matchesTab;
            switch (_selectedTab) {
              case _HomeTab.aguardandoSwab:
                matchesTab = isSwab;
              case _HomeTab.emAnalise:
                matchesTab = !isLiberado && !isSwab;
              case _HomeTab.resultados:
                matchesTab = isLiberado;
            }
            if (!matchesTab) return false;
            if (q.isEmpty) return true;
            return p.name.toLowerCase().contains(q) ||
                p.raca.toLowerCase().contains(q) ||
                p.nome_cliente.toLowerCase().contains(q);
          }).toList();
          final petIndex = pets.isEmpty
              ? 0
              : _selectedPetIndex.clamp(0, pets.length - 1);
          final isLoading = state is AppAtivacaoLoading;

          if (isLoading) {
            return const Box4PetsLoader();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(),
                const SizedBox(height: 18),
                _buildTabsRow(),
                const SizedBox(height: 12),
                if (pets.isNotEmpty) ...[
                  _buildPetStrip(pets, petIndex),
                  const SizedBox(height: 10),
                  _buildFocusedPetCard(pets[petIndex]),
                ] else if (allPets.isEmpty)
                  _buildEmptyPetCard()
                else
                  _buildEmptyFilterCard(),
                const SizedBox(height: 14),
                _buildContentCarousel(blog),
              ],
            ),
          );
        });
  }

  Widget _buildTopRow() {
    final hasLocal = _localPhotoPath != null;
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onProfileRequested?.call();
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: hasLocal
                  ? Image.file(File(_localPhotoPath!),
                      width: 48, height: 48, fit: BoxFit.cover)
                  : Icon(Icons.person_rounded,
                      color: AppColor.primary, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                prefixIcon:
                    Icon(Icons.search, color: AppColor.primary, size: 22),
                hintText: 'Buscar pet, raça ou cliente',
                hintStyle: TextStyle(
                  color: AppColor.primary.withOpacity(0.45),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                        icon: Icon(Icons.close_rounded,
                            color: AppColor.primary.withOpacity(0.5),
                            size: 18),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.15, end: 0);
  }

  Widget _buildTabsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTab('Aguardando Swab', _HomeTab.aguardandoSwab),
          const SizedBox(width: 8),
          _buildTab('Em Análise', _HomeTab.emAnalise),
          const SizedBox(width: 8),
          _buildTab('Resultados', _HomeTab.resultados),
        ],
      ),
    ).animate(delay: 160.ms).fadeIn(duration: 350.ms);
  }

  Widget _buildTab(String label, _HomeTab tab) {
    final selected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => _selectTab(tab),
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
          label,
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

  Widget _buildPetStrip(List<AppAtivacaoModel> pets, int selectedIndex) {
    if (pets.length <= 1) return const SizedBox.shrink();
    return SizedBox(
      height: 78,
      child: ListView.separated(
        controller: _petStripController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final pet = pets[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPetIndex = index);
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _centerSelectedPet(index));
            },
            child: SizedBox(
              width: 56,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColor.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE7DDF8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: pet.url != null
                          ? SmartNetworkImage(url: pet.url)
                          : Icon(Icons.pets,
                              color: AppColor.primary.withOpacity(0.5),
                              size: 20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pet.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColor.primary
                          : AppColor.primary.withOpacity(0.6),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 320.ms);
  }

  Widget _buildFocusedPetCard(AppAtivacaoModel pet) {
    final actions = <_PetActionData>[];
    if (pet.resultado) {
      actions.add(_PetActionData(
        label: 'Traços e Doenças',
        icon: Icons.science_outlined,
        color: AppColor.primary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TracosDoencas(
              box: pet.Case_ID,
              name: pet.name,
              ativacao: pet,
              url: pet.url,
            ),
          ),
        ),
      ));
    }
    if (pet.resultadoRaca) {
      actions.add(_PetActionData(
        label: 'Raças',
        icon: Icons.pets,
        color: AppColor.secondary,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TesteRaca(
              id: pet.Case_ID,
              name: pet.name,
              ativacao: pet,
            ),
          ),
        ),
      ));
    }
    if (pet.ourosTestes) {
      actions.add(_PetActionData(
        label: 'Outros',
        icon: Icons.description_outlined,
        color: AppColor.orange,
        onTap: () {
          HapticFeedback.selectionClick();
          _appAtivacaoBloc
              .add(AppAtivacaoSDownloadPDF(id: pet.Case_ID, name: pet.name));
        },
      ));
    }

    return _GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileDog(
                        dog: pet,
                        testeRaca: pet.resultadoRaca,
                        testeTracosDoencas: pet.resultado,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE7DDF8),
                    border: Border.all(
                      color: AppColor.primary.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: pet.url != null
                      ? SmartNetworkImage(url: pet.url)
                      : Icon(Icons.pets, color: AppColor.primary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        color: AppColor.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (pet.raca.isNotEmpty || pet.sexo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          [pet.raca, pet.sexo]
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          style: TextStyle(
                            color: AppColor.primary.withOpacity(0.55),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (actions.isEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Carregando resultados, aguarde!',
                style: TextStyle(
                  color: AppColor.primary.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                for (int i = 0; i < actions.length; i++) ...[
                  Expanded(
                    flex: actions[i].label.contains('Traços') ? 3 : 2,
                    child: _petActionPill(actions[i]),
                  ),
                  if (i < actions.length - 1) const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ],
      ),
    ).animate(delay: 240.ms).fadeIn(duration: 380.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _petActionPill(_PetActionData a) {
    return GestureDetector(
      onTap: a.onTap,
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: a.color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(a.icon, color: Colors.white, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilterCard() {
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final String title;
    final String subtitle;
    final IconData icon;
    if (hasSearch) {
      title = 'Nenhum resultado';
      subtitle = 'Tente outro nome, raça ou cliente';
      icon = Icons.search_off_rounded;
    } else {
      switch (_selectedTab) {
        case _HomeTab.aguardandoSwab:
          title = 'Nenhum pet aguardando swab';
          subtitle = 'Pets aguardando coleta aparecem aqui';
          icon = Icons.hourglass_top_rounded;
        case _HomeTab.emAnalise:
          title = 'Nenhum pet em análise';
          subtitle = 'Todos os pets já têm resultados liberados';
          icon = Icons.hourglass_empty_rounded;
        case _HomeTab.resultados:
          title = 'Nenhum resultado liberado';
          subtitle = 'Os resultados aparecem aqui quando ficam prontos';
          icon = Icons.task_alt_rounded;
      }
    }
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE7DDF8),
            ),
            child: Icon(
              icon,
              color: AppColor.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColor.primary.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms);
  }

  Widget _buildEmptyPetCard() {
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE7DDF8),
            ),
            child: Icon(Icons.pets, color: AppColor.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nenhum pet ativado',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Use o botão Ativar pra começar',
                  style: TextStyle(
                    color: AppColor.primary.withOpacity(0.55),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 240.ms).fadeIn(duration: 380.ms);
  }

  Widget _buildContentCarousel(List<BlogModel> blog) {
    if (blog.isEmpty) {
      return Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          'Nenhum conteúdo disponível',
          style: TextStyle(color: AppColor.primary.withOpacity(0.5)),
        ),
      );
    }

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final cardWidth = width * 0.74;
            final cardSpacing = width * 0.52;

            return SizedBox(
              height: 380,
              child: AnimatedBuilder(
                animation: _carouselController,
                builder: (context, _) {
                  final double page = _carouselController.positions.isNotEmpty &&
                          _carouselController.position.haveDimensions
                      ? (_carouselController.page ?? 0.0)
                      : _carouselController.initialPage.toDouble();

                  final centerIndex =
                      page.round().clamp(0, blog.length - 1);
                  final visible = <int>[];
                  for (int i = 0; i < blog.length; i++) {
                    if ((page - i).abs() <= 3.0) visible.add(i);
                  }
                  visible.sort((a, b) {
                    if (a == centerIndex) return 1;
                    if (b == centerIndex) return -1;
                    return (page - b).abs().compareTo((page - a).abs());
                  });

                  return Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      ...visible.map((index) {
                        final delta = page - index;
                        final absDelta = delta.abs().clamp(0.0, 2.0);
                        final clamped = delta.clamp(-1.5, 1.5);
                        final scale = (1 - (absDelta * 0.18)).clamp(0.6, 1.0);
                        final rotationY = clamped * 0.28;
                        final translateY = absDelta * 22;
                        final translateX = -clamped * cardSpacing;
                        final opacity =
                            (1 - (absDelta * 0.62)).clamp(0.32, 1.0);
                        final shadowOpacity =
                            (0.34 - (absDelta * 0.26)).clamp(0.05, 0.34);
                        final shadowBlur =
                            (38 - (absDelta * 24)).clamp(2.0, 38.0);
                        final shadowOffsetY =
                            (20 - (absDelta * 12)).clamp(2.0, 20.0);
                        final contentOp =
                            (1 - absDelta * 1.5).clamp(0.0, 1.0);

                        return IgnorePointer(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0015)
                              ..rotateY(rotationY)
                              ..translate(translateX, translateY)
                              ..scale(scale),
                            child: SizedBox(
                              width: cardWidth,
                              child: Opacity(
                                opacity: opacity,
                                child: _buildCarouselCard(
                                  blog[index],
                                  shadowOpacity: shadowOpacity,
                                  shadowBlur: shadowBlur,
                                  shadowOffsetY: shadowOffsetY,
                                  contentOpacity: contentOp,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            if (_carouselIndex >= 0 &&
                                _carouselIndex < blog.length) {
                              final item = blog[_carouselIndex];
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  opaque: false,
                                  barrierColor: Colors.transparent,
                                  transitionDuration:
                                      const Duration(milliseconds: 460),
                                  reverseTransitionDuration:
                                      const Duration(milliseconds: 320),
                                  pageBuilder: (_, __, ___) =>
                                      ScreenExpanded(blog: item, tag: item.id),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                    final curved = CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeOutQuart,
                                      reverseCurve: Curves.easeInCubic,
                                    );
                                    return FadeTransition(
                                      opacity: curved,
                                      child: ScaleTransition(
                                        scale: Tween<double>(
                                                begin: 0.95, end: 1.0)
                                            .animate(curved),
                                        child: child,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                          child: PageView.builder(
                            controller: _carouselController,
                            physics: const BouncingScrollPhysics(),
                            itemCount: blog.length,
                            onPageChanged: (index) {
                              HapticFeedback.lightImpact();
                              setState(() => _carouselIndex = index);
                            },
                            itemBuilder: (_, __) => const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ).animate(delay: 320.ms).fadeIn(duration: 420.ms),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(blog.length, (i) {
            final active = i == _carouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active
                    ? AppColor.primary
                    : AppColor.primary.withOpacity(0.22),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(
    BlogModel item, {
    required double shadowOpacity,
    required double shadowBlur,
    required double shadowOffsetY,
    required double contentOpacity,
  }) {
    final image = item.banner.isNotEmpty ? item.banner[0].url : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Hero(
        tag: item.id,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              color: const Color(0xFFE7DDF8),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(shadowOpacity),
                  blurRadius: shadowBlur,
                  spreadRadius: -4,
                  offset: Offset(0, shadowOffsetY),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity * 0.4),
                  blurRadius: shadowBlur * 0.6,
                  offset: Offset(0, shadowOffsetY * 0.5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SmartNetworkImage(url: image),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                          Colors.black.withOpacity(0.92),
                        ],
                        stops: const [0.2, 0.6, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.bottomLeft,
                    child: Opacity(
                      opacity: contentOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.titulo,
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 31,
                              height: 1.08,
                              letterSpacing: -31 * 0.04,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.subTitulo.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.subTitulo,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
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
