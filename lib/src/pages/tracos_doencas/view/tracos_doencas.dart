// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: non_constant_identifier_names

import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:Box4Pets/core/ui/widgets/parallax_background.dart';
import 'package:Box4Pets/src/Box4PetsApp.dart' show appNavigatorKey;
import 'package:Box4Pets/src/pages/doencas_uma_variante/views/doencas_uma_variante.dart';
import 'package:Box4Pets/src/pages/home/models/app_ativacao_model.dart';
import 'package:Box4Pets/src/pages/tracos/views/tracos.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/bloc/tracos_doencas_bloc.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_viwer_page.dart';
import 'package:Box4Pets/src/pages/parentesco/views/parentesco_screen.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/pdf_perfil_dna.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/shared_certificado.dart';
import 'package:Box4Pets/src/pages/tracos_doencas/view/components/shared_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class TracosDoencas extends StatefulWidget {
  final String box;
  final String name;
  final String? url;
  final AppAtivacaoModel ativacao;

  const TracosDoencas({
    Key? key,
    required this.box,
    required this.name,
    required this.url,
    required this.ativacao,
  }) : super(key: key);

  @override
  State<TracosDoencas> createState() => _TracosDoencasState();
}

class _TracosDoencasState extends State<TracosDoencas> {
  bool isCertificado = false;
  int _certCurrent = 0;
  int _certTotal = 0;
  bool _stillOnPage = true;
  bool _certGenerated = false;
  String? _certPath;
  bool _resultadoGenerated = false;
  bool _isGeneratingResultado = false;
  String? _resultadoPath;
  bool _isDnaGenerating = false;
  late final TracosDoencasBloc _tracosDoencasBloc;
  List<String> doenca_uma_variante = [];
  List<String> doenca_duas_variante = [];
  List<String> principais = [];
  List<String> todas = [];
  bool sharedLoad = false;
  final box = GetStorage();
  int progress = 0;
  String status = '';

  @override
  void initState() {
    super.initState();
    _tracosDoencasBloc = TracosDoencasBloc()
      ..add(TracosDoencasGetEvent(box: widget.box));
    final existing = box.read('Certificado_${widget.ativacao.name}.pdf');
    if (existing is String && existing.isNotEmpty) {
      _certGenerated = true;
      _certPath = existing;
    }
    final existingResult = box.read('Resultado_${widget.ativacao.name}.pdf');
    if (existingResult is String && existingResult.isNotEmpty) {
      _resultadoGenerated = true;
      _resultadoPath = existingResult;
    }
  }

  void _triggerGenerateResultado(TracosDoencasLoaded state) {
    if (_isGeneratingResultado || _resultadoGenerated) return;
    setState(() {
      _isGeneratingResultado = true;
      progress = 1;
      status = 'Iniciando...';
    });
    reportView(
      context,
      change: (msg, close, prog) {
        if (!_stillOnPage || !mounted) return;
        setState(() {
          status = msg;
          progress = prog;
        });
      },
      ativacao: widget.ativacao,
      duasVariantes: state.tracosDoencas.duas_variante,
      principais: state.tracosDoencas.principais_doencas_geneticas_da_raca,
      todas: state.tracosDoencas.todas_doencas_geneticas_avaliadas,
      umaVariate: state.tracosDoencas.uma_variante,
      name: widget.name,
      onComplete: (path) {
        if (_stillOnPage && mounted) {
          setState(() {
            _resultadoGenerated = true;
            _resultadoPath = path;
            _isGeneratingResultado = false;
            progress = 0;
            status = '';
          });
        }
        _showReadyDialog(
          path: path,
          title: 'Resultado pronto!',
          subtitle: 'Seu relatório completo está disponível pra visualizar.',
        );
      },
    );
  }

  @override
  void dispose() {
    _stillOnPage = false;
    _tracosDoencasBloc.close();
    super.dispose();
  }

  void changeStatus(String change, bool close, int progres) {
    if (!mounted) return;
    setState(() {
      status = change;
      progress = progres;
    });
  }

  void stopLoading() {
    if (!mounted) return;
    setState(() => isCertificado = false);
  }

  void _triggerGenerateCertificado(TracosDoencasLoaded state) {
    if (isCertificado || _certGenerated) return;
    setState(() {
      isCertificado = true;
      _certCurrent = 0;
      _certTotal =
          state.tracosDoencas.principais_doencas_geneticas_da_raca.length;
    });
    reportViewCertificado(
      name: widget.name,
      context,
      ativacao: widget.ativacao,
      stopLoading: stopLoading,
      principais: state.tracosDoencas.principais_doencas_geneticas_da_raca,
      onProgress: (current, total) {
        if (!_stillOnPage || !mounted) return;
        setState(() {
          _certCurrent = current;
          _certTotal = total;
        });
      },
      onComplete: (path) {
        if (_stillOnPage && mounted) {
          setState(() {
            _certGenerated = true;
            _certPath = path;
          });
        }
        _showReadyDialog(
          path: path,
          title: 'Certificado pronto!',
          subtitle: 'Sua análise genética está disponível pra visualizar.',
        );
      },
    );
  }

  void _openShareOptions(TracosDoencasLoaded state) {
    final existing = box.read('Resultado_${widget.ativacao.name}.pdf');
    if (existing == null) {
      _triggerShare(state);
      return;
    }
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
              'Relatório',
              style: GoogleFonts.dmSans(
                color: AppColor.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Já existe um relatório anterior. O que deseja?',
              textAlign: TextAlign.center,
              style: GoogleFonts.archivo(
                color: AppColor.primary.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _BottomSheetOption(
              icon: Icons.refresh_rounded,
              label: 'Gerar novo relatório',
              onTap: () {
                Navigator.pop(ctx);
                _triggerShare(state);
              },
            ),
            const SizedBox(height: 8),
            _BottomSheetOption(
              icon: Icons.description_outlined,
              label: 'Usar relatório anterior',
              onTap: () {
                Navigator.pop(ctx);
                final path = box.read('Resultado_${widget.ativacao.name}.pdf');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PdfViwerPage(path: path)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReadyDialog({
    required String path,
    required String title,
    required String subtitle,
  }) {
    final ctx = appNavigatorKey.currentContext;
    if (ctx == null) return;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColor.secondary.withOpacity(0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_rounded,
                    color: AppColor.secondary, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: AppColor.primary.withOpacity(0.6),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: Text(
                        'Agora não',
                        style: TextStyle(
                          color: AppColor.primary.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                        appNavigatorKey.currentState?.push(
                          MaterialPageRoute(
                            builder: (_) => PdfViwerPage(path: path),
                          ),
                        );
                      },
                      child: const Text(
                        'Ver agora',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerShare(TracosDoencasLoaded state) {
    reportView(
      context,
      change: changeStatus,
      ativacao: widget.ativacao,
      duasVariantes: state.tracosDoencas.duas_variante,
      principais: state.tracosDoencas.principais_doencas_geneticas_da_raca,
      todas: state.tracosDoencas.todas_doencas_geneticas_avaliadas,
      umaVariate: state.tracosDoencas.uma_variante,
      name: widget.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ParallaxBackground(
        child: BlocListener<TracosDoencasBloc, TracosDoencasState>(
          bloc: _tracosDoencasBloc,
          listener: (context, state) {
            if (state is TracosDoencasLoaded) {
              setState(() {
                doenca_uma_variante = state.tracosDoencas.uma_variante;
                doenca_duas_variante = state.tracosDoencas.duas_variante;
                principais = state.tracosDoencas
                    .principais_doencas_geneticas_da_raca;
                todas = state.tracosDoencas.todas_doencas_geneticas_avaliadas;
              });
            }
          },
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: BlocBuilder<TracosDoencasBloc, TracosDoencasState>(
                    bloc: _tracosDoencasBloc,
                    builder: (context, state) {
                      if (state is TracosDoencasLoaded) {
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
          BlocBuilder<TracosDoencasBloc, TracosDoencasState>(
            bloc: _tracosDoencasBloc,
            builder: (context, state) {
              return _GlassIconButton(
                icon: Icons.ios_share_rounded,
                background: AppColor.orange,
                iconColor: Colors.white,
                onTap: state is TracosDoencasLoaded
                    ? () => _openShareOptions(state)
                    : () {},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TracosDoencasLoaded state) {
    final pet = widget.ativacao;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: _buildPetCard(pet),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ResultadoGenPill(
                  loading: _isGeneratingResultado,
                  generated: _resultadoGenerated,
                  progress: progress,
                  onTap: () {
                    if (_resultadoGenerated && _resultadoPath != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PdfViwerPage(path: _resultadoPath!),
                        ),
                      );
                    } else {
                      _triggerGenerateResultado(state);
                    }
                  },
                ),
              ],
            ),
          ),
          if (progress > 0 && _isGeneratingResultado) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProgress(),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: _buildSectionTitle(
              'Análise do DNA',
              'Avaliamos o potencial de doenças genéticas e traços físicos',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildGenesGrid(state),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildSectionTitle(
              'Doenças',
              'Riscos genéticos detectados na análise',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.looks_one_rounded,
                  iconColor: AppColor.secondary,
                  title: 'Uma variante detectada',
                  subtitle: 'Sem risco aumentado',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoencasUmaVariante(
                        id: doenca_uma_variante,
                        title: 'Doenças com uma variante detectada',
                        box: widget.box,
                        especie: widget.ativacao.especie,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ActionRow(
                  icon: Icons.looks_two_rounded,
                  iconColor: AppColor.orange,
                  title: 'Duas variantes detectadas',
                  subtitle: 'Risco aumentado de doença',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoencasUmaVariante(
                        id: doenca_duas_variante,
                        title: 'Doenças com duas variantes detectadas',
                        box: widget.box,
                        especie: widget.ativacao.especie,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _ActionRow(
                  icon: Icons.priority_high_rounded,
                  iconColor: const Color(0xFFE85D75),
                  title: 'Principais doenças genéticas da raça',
                  subtitle: 'Doenças mais comuns nesta raça',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoencasUmaVariante(
                        id: principais,
                        title: 'Principais doenças genéticas de raça',
                        box: widget.box,
                        especie: widget.ativacao.especie,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _CertificateButton(
                  loading: isCertificado,
                  generated: _certGenerated,
                  current: _certCurrent,
                  total: _certTotal,
                  onTap: () => _triggerGenerateCertificado(state),
                ),
                if (_certGenerated && _certPath != null) ...[
                  const SizedBox(height: 8),
                  _GeneratedCertificateRow(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViwerPage(path: _certPath!),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildSectionTitle(
              'Traços',
              'Características genéticas físicas e de pelagem',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _TracoRow(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  title: 'Cor da camada da base dos pelos',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Tracos(
                        especie: widget.ativacao.especie,
                        id: 'Cor da camada da base dos pelos',
                        box: widget.box,
                        subTitle:
                            'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem.\n\nOs genes da cor da pelagem básica estão ligados ao fato de o seu cão ter algum pelo escuro e, se tiver, se o pelo escuro é preto, marrom, cinza ou marrom claro.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _TracoRow(
                  icon: Icons.invert_colors_rounded,
                  iconColor: const Color(0xFF06B6D4),
                  title: 'Modificadores da coloração',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Tracos(
                        especie: widget.ativacao.especie,
                        box: widget.box,
                        id: 'Modificadores da coloração',
                        subTitle:
                            'Diversos genes influenciam a coloração da pelagem em cães, e sua interação complexa pode resultar em uma ampla variedade de tonalidades e padrões. Em alguns casos, efeitos genéticos adicionais, por vezes desconhecidos, também podem desempenhar um papel na determinação da cor e do padrão da pelagem.\n\nOs genes modificadores da cor da pelagem que testamos explicam os padrões de pelagem na maioria dos cães. Ainda não podemos testar alguns padrões de cores, por exemplo, alguns tipos de manchas.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _TracoRow(
                  icon: Icons.brush_rounded,
                  iconColor: AppColor.secondary,
                  title: 'Características da pelagem',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Tracos(
                        especie: widget.ativacao.especie,
                        box: widget.box,
                        id: 'Características da pelagem',
                        subTitle:
                            'Diversos genes estão ativamente envolvidos e afetam a característica da pelagem, e interagem entre si de maneira complexa. A combinação desses genes é responsável por explicar as características da pelagem nas raças dos cães e gatos.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _TracoRow(
                  icon: Icons.pets_rounded,
                  iconColor: AppColor.primary,
                  title: 'Características físicas',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Tracos(
                        especie: widget.ativacao.especie,
                        box: widget.box,
                        id: 'Características físicas',
                        subTitle:
                            'Várias características corporais tais como o formato da cabeça e da cauda são influenciados por genes. Um número maior de genes relacionados a características corporais estão sendo constantemente estudados.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _buildSectionTitle(
              'Genética Avançada',
              'Perfil de DNA e parentesco genético',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.biotech_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Perfil de DNA',
                  subtitle: 'Gera o relatório completo de marcadores',
                  onTap: () async {
                    if (_isDnaGenerating) return;
                    setState(() => _isDnaGenerating = true);
                    try {
                      await reportViewDNA(
                        context,
                        ativacao: widget.ativacao,
                      );
                    } finally {
                      if (mounted) setState(() => _isDnaGenerating = false);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _ActionRow(
                  icon: Icons.family_restroom_rounded,
                  iconColor: const Color(0xFF0EA5E9),
                  title: 'Teste de Parentesco',
                  subtitle: 'Verifique a relação genética entre pets',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentescoScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(AppAtivacaoModel pet) {
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
                image: widget.url != null
                    ? DecorationImage(
                        image: NetworkImage(widget.url!), fit: BoxFit.cover)
                    : null,
              ),
              child: widget.url == null
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
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'TRAÇOS & DOENÇAS',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
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
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.archivo(
            color: AppColor.primary.withOpacity(0.55),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Gerando relatório · $progress%',
                style: GoogleFonts.dmSans(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'O relatório contém um grande número de genes. Esse processo ocorre apenas uma vez.',
            style: GoogleFonts.archivo(
              color: AppColor.primary.withOpacity(0.6),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenesGrid(TracosDoencasLoaded state) {
    final t = state.tracosDoencas;
    final tiles = [
      _GeneTileData(
        value: '${t.genes_sem_alteracao}',
        label: 'Genes sem alteração',
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF22C55E),
      ),
      _GeneTileData(
        value: '${t.gene_com_uma_variante_detectada}',
        label: 'Portador de 1 variante',
        icon: Icons.warning_amber_rounded,
        color: AppColor.orange,
      ),
      _GeneTileData(
        value: '${t.gene_com_duas_variante_detectada}',
        label: 'Risco aumentado · 2 variantes',
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFE85D75),
      ),
      _GeneTileData(
        value: '${t.tracos}',
        label: 'Traços',
        icon: Icons.science_rounded,
        color: AppColor.primary,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, i) {
        return _GeneTile(data: tiles[i])
            .animate(delay: (60 * i).ms)
            .fadeIn(duration: 320.ms)
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}

class _GeneTileData {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _GeneTileData({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _GeneTile extends StatelessWidget {
  final _GeneTileData data;
  const _GeneTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final intValue = int.tryParse(data.value) ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(data.icon, color: data.color, size: 16),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                        begin: 0, end: intValue.toDouble()),
                    duration: Duration(
                        milliseconds:
                            intValue > 0 ? 900 + intValue * 30 : 0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final displayed = value.round().toString().padLeft(
                          2, '0');
                      return Text(
                        displayed,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          color: data.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 59,
                          height: 1.0,
                          letterSpacing: -2.1,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Text(
                  data.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.archivo(
                    color: AppColor.primary.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
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
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
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
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
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
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.archivo(
                      color: AppColor.primary.withOpacity(0.55),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
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

class _CertificateButton extends StatelessWidget {
  final bool loading;
  final bool generated;
  final int current;
  final int total;
  final VoidCallback onTap;
  const _CertificateButton({
    required this.loading,
    required this.generated,
    required this.current,
    required this.total,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).round();
    return GestureDetector(
      onTap: loading || generated
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onTap();
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColor.secondary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColor.secondary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: loading && total > 0
                  ? Text(
                      '$pct%',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                    )
                  : const Icon(Icons.verified_rounded,
                      color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Certificado de análise genética',
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loading
                        ? (total > 0
                            ? 'Gerando · $current de $total'
                            : 'Gerando certificado...')
                        : (generated
                            ? 'Pronto para visualizar'
                            : 'Documento oficial assinado'),
                    style: GoogleFonts.archivo(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _GerarPill(generated: generated, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _GerarPill extends StatelessWidget {
  final bool generated;
  final bool loading;
  const _GerarPill({required this.generated, required this.loading});

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData? icon;
    if (loading) {
      label = 'Gerando';
      icon = null;
    } else if (generated) {
      label = 'Gerado';
      icon = Icons.check_rounded;
    } else {
      label = 'Gerar';
      icon = null;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedCertificateRow extends StatelessWidget {
  final VoidCallback onTap;
  const _GeneratedCertificateRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.secondary.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColor.secondary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.task_alt_rounded,
                  color: AppColor.secondary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Certificado gerado',
                    style: GoogleFonts.dmSans(
                      color: AppColor.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Toque pra visualizar',
                    style: GoogleFonts.archivo(
                      color: AppColor.primary.withOpacity(0.55),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.visibility_rounded,
                      color: Colors.white, size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Ver',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TracoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  const _TracoRow({
    required this.icon,
    required this.iconColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
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

class _ResultadoGenPill extends StatelessWidget {
  final bool loading;
  final bool generated;
  final int progress;
  final VoidCallback onTap;
  const _ResultadoGenPill({
    required this.loading,
    required this.generated,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (loading) return;
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: generated
              ? AppColor.primary
              : (loading
                  ? AppColor.primary.withOpacity(0.4)
                  : AppColor.primary),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.22),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              loading
                  ? Icons.hourglass_top_rounded
                  : (generated
                      ? Icons.task_alt_rounded
                      : Icons.description_outlined),
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              loading
                  ? (progress > 0
                      ? 'Gerando · $progress%'
                      : 'Gerando...')
                  : (generated
                      ? 'Resultado gerado · Ver'
                      : 'Gerar Resultado Completo'),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EEFC),
          borderRadius: BorderRadius.circular(16),
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
              child: Icon(icon, color: AppColor.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.archivo(
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColor.primary.withOpacity(0.5), size: 22),
          ],
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
