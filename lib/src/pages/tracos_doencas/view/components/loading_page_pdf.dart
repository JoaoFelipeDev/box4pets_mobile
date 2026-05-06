// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';

class LoadingPagePdf extends StatefulWidget {
  String status;
  LoadingPagePdf({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  _LoadingPagePdfState createState() => _LoadingPagePdfState();
}

class _LoadingPagePdfState extends State<LoadingPagePdf> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(
              height: 15,
            ),
            Text(
              'Gerando documento...',
              style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              'Isso pode levar até um minuto',
              style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            Text(
              widget.status,
              style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
