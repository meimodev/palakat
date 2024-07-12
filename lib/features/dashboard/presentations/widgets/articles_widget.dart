// import 'package:flutter/material.dart';
// import 'package:palakat/core/constants/constants.dart';
// import 'package:palakat/core/widgets/widgets.dart';
// import 'widgets.dart';
//
// class ArticlesWidget extends StatelessWidget {
//   const ArticlesWidget({
//     super.key,
//     required this.onPressedViewAll,
//     required this.data,
//   });
//
//   final void Function() onPressedViewAll;
//   final List<String> data;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         SegmentTitleWidget(
//           onPressedViewAll: onPressedViewAll,
//           count: data.length,
//           title: 'Articles',
//         ),
//         Gap.h6,
//         ...data.map(
//           (e) => Padding(
//             padding: EdgeInsets.only(
//               bottom: BaseSize.h6,
//             ),
//             child: CardArticlesWidget(
//               title: e,
//               onPressedCard: () {
//                 print(e);
//               },
//               categories: ["category 1", "category 2", "category 3"],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
