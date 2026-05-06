// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Box4Pets/config/app_color.dart';

class AppBarCustom extends StatefulWidget {
  final void Function() callback;
  const AppBarCustom({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  _AppBarCustomState createState() => _AppBarCustomState();
}

class _AppBarCustomState extends State<AppBarCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              onPressed: widget.callback,
              icon: Icon(
                Icons.menu,
                color: AppColor.primary,
                size: 30,
              )),
          Image.asset('assets/images/logo_app_bar.png'),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/activation'),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppColor.secondary,
                    size: 30,
                  ),
                ),
                Text(
                  'Ativar',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 10.77,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
