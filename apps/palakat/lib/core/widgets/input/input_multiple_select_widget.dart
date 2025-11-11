// import 'package:flutter/material.dart';
// import 'package:palakat/core/assets/assets.gen.dart';
// import 'package:palakat/core/constants/constants.dart';
// import 'package:palakat/core/utils/utils.dart';
//
// class InputMultipleSelectWidget<T> extends StatelessWidget {
//   const InputMultipleSelectWidget({
//     super.key,
//     this.label,
//     this.hintText,
//     this.onBodyTap,
//     this.maxItem = 3,
//     this.value = const [],
//     required this.getValue,
//     required this.getLabel,
//     required this.onRemove,
//   });
//
//   final String? label;
//   final String? hintText;
//   final VoidCallback? onBodyTap;
//   final List<T> value;
//   final dynamic Function(T) getValue;
//   final String Function(T) getLabel;
//   final Function(T) onRemove;
//   final int maxItem;
//
//   List<Widget> get widgetItems {
//     if (value.length >= maxItem) {
//       return [
//         ...value
//             .sublist(0, maxItem)
//             .map(
//               (e) => _createItem<T>(
//                 getLabel(e),
//                 onRemove: () {
//                   onRemove(e);
//                 },
//               ),
//             )
//             .toList(),
//         if (value.length > maxItem)
//           _createItem(
//             "+${value.length - maxItem} Others",
//           )
//       ];
//     }
//
//     return value
//         .map(
//           (e) => _createItem<T>(
//             getLabel(e),
//             onRemove: () {
//               onRemove(e);
//             },
//           ),
//         )
//         .toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (label != null)
//           Text(
//             label ?? '',
//             style: TypographyTheme.textMRegular
//                 .fontColor(BaseColor.neutral.shade60),
//           ),
//         GestureDetector(
//           onTap: onBodyTap,
//           child: Container(
//             padding: value.isEmpty
//                 ? EdgeInsets.zero
//                 : EdgeInsets.symmetric(vertical: BaseSize.h8),
//             decoration: BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(
//                   width: 1,
//                   color: BaseColor.neutral.shade30,
//                 ),
//               ),
//             ),
//             child: Row(
//                 crossAxisAlignment: value.isEmpty
//                     ? CrossAxisAlignment.center
//                     : CrossAxisAlignment.start,
//                 children: [
//                   if (value.isNotEmpty) ...[
//                     Expanded(
//                         child: Wrap(
//                       spacing: 8.0, // gap between adjacent chips
//                       runSpacing: 4.0,
//                       children: widgetItems,
//                     )),
//                   ] else ...[
//                     Expanded(
//                         child: Text(
//                       hintText ?? '',
//                       style: TypographyTheme.textLRegular.toNeutral50,
//                     ))
//                   ],
//                   IconButton(
//                       padding: EdgeInsets.zero,
//                       splashColor: Colors.transparent,
//                       highlightColor: Colors.transparent,
//                       onPressed: onBodyTap,
//                       icon: Assets.icons.line.chevronDown.svg())
//                 ]),
//           ),
//         )
//       ],
//     );
//   }
// }
//
// Widget _createItem<T>(String title, {VoidCallback? onRemove}) {
//   return (ChipsWidget.custom(
//     color: BaseColor.primary1,
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Flexible(
//           child: Text(
//             title,
//             style: TypographyTheme.textMRegular.toNeutral70,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Gap.w8,
//         if (onRemove != null)
//           SizedBox(
//             width: 20,
//             height: 20,
//             child: IconButton(
//               padding: EdgeInsets.zero,
//               splashColor: Colors.transparent,
//               highlightColor: Colors.transparent,
//               onPressed: onRemove,
//               icon: Assets.icons.line.times.svg(
//                 colorFilter: BaseColor.neutral.shade70.filterSrcIn,
//               ),
//             ),
//           )
//       ],
//     ),
//   ));
// }
