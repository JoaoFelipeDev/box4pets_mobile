// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:ui';

import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

class PdfViwerPage extends StatefulWidget {
  final String path;
  const PdfViwerPage({Key? key, required this.path}) : super(key: key);

  @override
  State<PdfViwerPage> createState() => _PdfViwerPageState();
}

class _PdfViwerPageState extends State<PdfViwerPage> {
  late Future<PDFDocument> docFuture;

  Future<PDFDocument> _loadPdf() async {
    final file = File(widget.path);
    return PDFDocument.fromFile(file);
  }

  @override
  void initState() {
    super.initState();
    docFuture = _loadPdf();
  }

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    final file = File(widget.path);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Resultado Box4Pets',
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: topInset + 60),
            child: FutureBuilder<PDFDocument>(
              future: docFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Box4PetsLoader();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar PDF',
                        style: GoogleFonts.archivo(
                            color: AppColor.primary.withOpacity(0.6))),
                  );
                } else if (snapshot.hasData) {
                  return PDFViewer(
                    document: snapshot.data!,
                    showNavigation: true,
                    showPicker: false,
                    pickerButtonColor: AppColor.primary,
                  );
                }
                return Center(
                  child: Text('PDF não encontrado',
                      style: GoogleFonts.archivo(
                          color: AppColor.primary.withOpacity(0.6))),
                );
              },
            ),
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
                      _CircleIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Resultado',
                          style: GoogleFonts.dmSans(
                            color: AppColor.primary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.ios_share_rounded,
                        onTap: _share,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

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
