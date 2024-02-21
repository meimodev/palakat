import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class InputCardPhotoWidget extends StatefulWidget {
  const InputCardPhotoWidget({
    super.key,
    required this.title,
    required this.onChangePhoto,
    this.required = false,
  });

  final String title;
  final void Function(String? base64String) onChangePhoto;
  final bool required;

  @override
  State<InputCardPhotoWidget> createState() => _InputCardPhotoWidgetState();
}

class _InputCardPhotoWidgetState extends State<InputCardPhotoWidget> {
  File? imageFile;

  void handleOnTapRemovePhoto() {
    setState(() => imageFile = null);
    widget.onChangePhoto(null);
  }

  Future<void> handleOnTapUploadPhoto() async {
    File? pickedFile = await FilePickerUtil.pickFile(imagesOnly: true);

    if (pickedFile == null) {
      //canceled by user
      return;
    }
    setState(() {
      imageFile = pickedFile;
    });
    final String? base64 = await FilePickerUtil.fileToBase64(pickedFile);
    widget.onChangePhoto(base64);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: TypographyTheme.textMRegular.toNeutral60,
            ),
            widget.required
                ? Text(
                    "*",
                    style: TypographyTheme.textMRegular.toRed500,
                  )
                : const SizedBox(),
          ],
        ),
        Gap.h16,
        SizedBox(
          height: BaseSize.customHeight(200),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: imageFile != null
                    ? Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(BaseSize.radiusMd),
                        ),
                        child: Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const SizedBox(),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: InkWell(
                  onTap: handleOnTapUploadPhoto,
                  child: DottedBorder(
                    color: BaseColor.neutral.shade40,
                    strokeWidth: BaseSize.customWidth(1),
                    dashPattern: const [5, 0, 5],
                    borderType: BorderType.RRect,
                    radius: Radius.circular(BaseSize.radiusMd),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        imageFile != null
                            ? const SizedBox()
                            : Center(
                                child: Assets.icons.fill.camera.svg(
                                  width: BaseSize.w40,
                                  height: BaseSize.h40,
                                  colorFilter: BaseColor.primary3.filterSrcIn,
                                ),
                              ),
                        Gap.h4,
                        imageFile != null
                            ? const SizedBox()
                            : Text(
                                LocaleKeys.text_uploadPhoto.tr(),
                                style: TypographyTheme.textMRegular.toPrimary,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: BaseSize.w12,
                top: BaseSize.w12,
                child: imageFile != null
                    ? GestureDetector(
                        onTap: handleOnTapRemovePhoto,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 2,
                                offset: const Offset(0, 3),
                                color: Colors.black.withOpacity(.125),
                              ),
                            ],
                            shape: BoxShape.circle,
                          ),
                          width: BaseSize.w32,
                          height: BaseSize.w32,
                          child: Assets.icons.fill.xCircle.svg(
                            colorFilter: BaseColor.white.filterSrcIn,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
