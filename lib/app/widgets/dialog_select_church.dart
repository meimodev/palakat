import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/shared/theme.dart';

class DialogSelectChurch extends StatelessWidget {
  const DialogSelectChurch({
    Key? key,
    required this.onSelectedChurch,
    required this.churches,
  }) : super(key: key);

  final Function(Church church) onSelectedChurch;
  final List<Church> churches;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(9.sp),
      ),
      backgroundColor: Palette.scaffold,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.small.w,
          vertical: Insets.small.h,
        ),
        child: SizedBox(
          height: 360.h,
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'Select Church',
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      fontSize: 24.sp,
                    ),
              ),
              SizedBox(height: Insets.small.h),
              Expanded(
                child: ListView.builder(
                  itemCount: churches.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => _CardChurchSelection(
                    church: churches[index],
                    onPressed: () {
                      onSelectedChurch(churches[index]);
                      Navigator.pop(context);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CardChurchSelection extends StatelessWidget {
  const _CardChurchSelection({
    Key? key,
    required this.onPressed,
    required this.church,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Church church;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Insets.small.h * .5),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: BorderRadius.circular(9.sp),
        color: Palette.cardForeground,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Insets.small.w,
              vertical: Insets.small.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  church.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: Insets.small.h * .5),
                Text(
                  church.location,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      ?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}