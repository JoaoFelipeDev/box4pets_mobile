// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:Box4Pets/config/app_color.dart';
import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

class PdfViwerPage extends StatefulWidget {
  final String path;
  PdfViwerPage({
    Key? key,
    required this.path,
  }) : super(key: key);

  @override
  State<PdfViwerPage> createState() => _PdfViwerPageState();
}

class _PdfViwerPageState extends State<PdfViwerPage> {
  late Future<PDFDocument> docFuture;

   Future<PDFDocument> _loadPdf() async {
    File file = File(widget.path);
    return await PDFDocument.fromFile(file);
  }

  _pdf() async {
     docFuture = _loadPdf();
  }

  @override
  void initState() {
    _pdf();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    File file = File(widget.path);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Navegação Box4Pets"),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColor.secondary,
          child: Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () async {
            await Share.shareXFiles([XFile(file.path)],
                subject: 'Compartilhando resultados de testes');
          }),
      body: FutureBuilder<PDFDocument>(
        future: docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading PDF'));
          } else if (snapshot.hasData) {
            final doc = snapshot.data!;
            return PDFViewer(document: doc);
          } else {
            return Center(child: Text('No PDF found'));
          }
        },
      ),
    ),);
  }
}
