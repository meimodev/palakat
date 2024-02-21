import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class UploadFileWidget extends StatefulWidget {
  final String fileText;
  final List<File> files;
  final Function(int, String) onRemoveFile;
  final Function() onPickFiles;

  const UploadFileWidget({
    Key? key,
    required this.fileText,
    required this.files,
    required this.onRemoveFile,
    required this.onPickFiles,
  }) : super(key: key);

  @override
  _UploadFileWidgetState createState() => _UploadFileWidgetState();
}

class _UploadFileWidgetState extends State<UploadFileWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.fileText != ""
        ? Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.fileText
                          .split(', ')
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final fileName = entry.value;
                        return ShowSelectedFiles(
                          fileName: fileName,
                          onRemove: index,
                          onRemoveCallback: widget.onRemoveFile,
                          files: widget.files,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Gap.w16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    DottedBorder(
                      borderType: BorderType.RRect,
                      dashPattern: const [10, 5],
                      radius: const Radius.circular(12),
                      padding: const EdgeInsets.all(6),
                      color: BaseColor.neutral.shade40,
                      child: IconButton(
                        onPressed: widget.onPickFiles,
                        icon: Assets.icons.fill.plusGreyCircle.svg(
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        : Expanded(
            child: DottedBorder(
              borderType: BorderType.RRect,
              dashPattern: const [10, 5],
              radius: const Radius.circular(12),
              padding: const EdgeInsets.all(6),
              color: BaseColor.neutral.shade40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onPickFiles,
                    icon: Assets.icons.fill.plusGreenCircle.svg(
                      width: 18,
                      height: 18,
                    ),
                  ),
                  Text(
                    LocaleKeys.text_addFile.tr(),
                    style: TypographyTheme.textLRegular.fontColor(
                      BaseColor.neutral.shade60,
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class ShowSelectedFiles extends StatefulWidget {
  String fileName;
  final List<File> files;

  final int onRemove;
  final Function(int, String) onRemoveCallback;
  ShowSelectedFiles({
    super.key,
    required this.fileName,
    required this.files,
    required this.onRemove,
    required this.onRemoveCallback,
  });

  @override
  State<ShowSelectedFiles> createState() => _ShowSelectedFilesState();
}

class _ShowSelectedFilesState extends State<ShowSelectedFiles> {
  @override
  Widget build(BuildContext context) {
    String fileExtension = widget.fileName.split('.').last;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 4, 0),
          decoration: BoxDecoration(
            // color: Colors.amber,
            border: Border.all(color: BaseColor.neutral.shade20),
            borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          ),
          child: Row(
            children: [
              fileExtension == "pdf"
                  ? Assets.images.pdf.image(width: 28, height: 28)
                  : Assets.images.jpg.image(width: 28, height: 28),
              Text(
                widget.fileName,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                onPressed: () {
                  widget.onRemoveCallback(widget.onRemove, widget.fileName);
                },
                icon: Assets.icons.line.xCircle.svg(
                  width: 18,
                  height: 18,
                  colorFilter: BaseColor.neutral.shade60.filterSrcIn,
                ),
              ),
            ],
          ),
        ),
        Gap.w8,
      ],
    );
  }
}
