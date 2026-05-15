// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Box4Pets/config/app_color.dart';
import 'package:Box4Pets/src/pages/ativacao/views/activation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarCustom extends StatelessWidget {
  const AppBarCustom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 6, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 36, height: 36),
          SvgPicture.asset(
            'assets/logoB4p.svg',
            height: 28,
            fit: BoxFit.contain,
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (_) => const Activation(),
              ),
            ),
            borderRadius: BorderRadius.circular(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ativar',
                  style: TextStyle(
                    color: AppColor.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
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
