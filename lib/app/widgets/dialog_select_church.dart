import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat/app/widgets/text_field_wrapper.dart';
import 'package:palakat/data/models/church.dart';
import 'package:palakat/shared/theme.dart';

class DialogSelectChurch extends StatefulWidget {
  const DialogSelectChurch({
    Key? key,
    required this.onSelectedChurch,
    required this.churches,
  }) : super(key: key);

  final Function(Church church) onSelectedChurch;
  final List<Church> churches;

  @override
  State<DialogSelectChurch> createState() => _DialogSelectChurchState();
}

class _DialogSelectChurchState extends State<DialogSelectChurch> {
  final tecSearch = TextEditingController();

  List<Church> churches = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      final c = widget.churches;
      c.shuffle();
      churches = c;
    });
  }

  @override
  void dispose() {
    tecSearch.dispose();
    super.dispose();
  }

  void onSearchText(String text) {
    if (text.isEmpty) {
      setState(() {
        final c = widget.churches;
        c.shuffle();
        churches = c;
      });
      return;
    }
    setState(() {
      churches = widget.churches
          .where((element) =>
              element.name.toUpperCase().contains(text.toUpperCase().trim()) ||
              element.location
                  .toUpperCase()
                  .contains(text.toUpperCase().trim()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: Palette.scaffold,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Insets.medium.w,
          vertical: Insets.medium.h,
        ),
        child: SizedBox(
          height: 400.h,
          width: double.infinity,
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: GestureDetector(
                          child: const Icon(Icons.close_outlined),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      )),
                  Center(
                    child: Text(
                      'Select Church',
                      style: TextStyle(
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Insets.medium.h),
              TextFieldWrapper(
                textEditingController: tecSearch,
                labelText: "Find Church",
                startIconData: Icons.search_outlined,
                fontColor: Colors.grey,
                onChangeText: onSearchText,
              ),
              SizedBox(height: Insets.small.h * .5),
              Expanded(
                child: ListView.builder(
                  itemCount: churches.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => _CardChurchSelection(
                    church: churches[index],
                    onPressed: () {
                      widget.onSelectedChurch(churches[index]);
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  church.location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
