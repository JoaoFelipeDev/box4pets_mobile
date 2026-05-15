import 'package:Box4Pets/config/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a native-style iOS wheel picker for selecting one option from [items].
///
/// Returns the selected item, or `null` if the user dismissed via "Cancelar".
Future<String?> showCupertinoWheelPicker({
  required BuildContext context,
  required String title,
  required List<String> items,
  String? selected,
}) {
  HapticFeedback.selectionClick();
  final initialIndex = selected != null && items.contains(selected)
      ? items.indexOf(selected)
      : 0;
  int tempIndex = initialIndex;

  return showCupertinoModalPopup<String>(
    context: context,
    builder: (ctx) {
      return Material(
        type: MaterialType.transparency,
        child: Container(
          height: 320,
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator.resolveFrom(ctx),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColor.primary.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            Navigator.of(ctx).pop(items[tempIndex]),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 36,
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex,
                    ),
                    onSelectedItemChanged: (i) => tempIndex = i,
                    children: [
                      for (final item in items)
                        Center(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
