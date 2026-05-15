import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TracosFiltroPage extends StatefulWidget {
  const TracosFiltroPage({Key? key}) : super(key: key);

  @override
  State<TracosFiltroPage> createState() => _TracosFiltroPageState();
}

class _TracosFiltroPageState extends State<TracosFiltroPage> {
  late final WebViewController _controller;
  bool _loading = true;
  double _progress = 0;

  static const String _url = 'https://filtrobox4pets.netlify.app';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) {
            if (mounted) setState(() => _progress = p / 100);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topInset + 56),
            child: WebViewWidget(controller: _controller),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.white.withOpacity(0.7),
                  padding: EdgeInsets.fromLTRB(12, topInset + 6, 12, 8),
                  child: Row(
                    children: [
                      _GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Doenças & Traços',
                          style: GoogleFonts.dmSans(
                            color: AppColor.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      _GlassIconButton(
                        icon: Icons.refresh_rounded,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _controller.reload();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_loading && _progress < 1)
            Positioned(
              top: topInset + 54,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: AppColor.primary.withOpacity(0.08),
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColor.primary),
                minHeight: 2,
              ),
            ),
          if (_loading && _progress < 0.15)
            const Positioned.fill(child: Box4PetsLoader()),
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
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColor.primary),
      ),
    );
  }
}
