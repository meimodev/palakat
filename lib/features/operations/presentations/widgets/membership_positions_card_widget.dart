import 'package:flutter/material.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/membership.dart';
import 'package:palakat/core/widgets/widgets.dart';

class MembershipPositionsCardWidget extends StatelessWidget {
  const MembershipPositionsCardWidget({super.key, required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Positions ${membership.membershipPositions.length}",
          style: BaseTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gap.h6,
        Wrap(
          spacing: BaseSize.w8,
          runSpacing: BaseSize.h8,
          children: membership.membershipPositions.map((pos) {
            return ChipsWidget(title: pos.name);
          }).toList(),
        ),
      ],
    );
  }
}
