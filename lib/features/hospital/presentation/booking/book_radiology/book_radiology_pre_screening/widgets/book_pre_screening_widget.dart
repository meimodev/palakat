import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/button/button_widget.dart';
import 'package:halo_hermina/features/domain.dart';
import 'widgets.dart';

class BookPreScreeningScreenWidget extends StatefulWidget {
  const BookPreScreeningScreenWidget({
    super.key,
    required this.onChangedQuestionnaireValue,
    required this.disableSubmitButton,
    required this.onTapSubmit,
    required this.questionnaires,
  });

  final void Function(int index, bool value) onChangedQuestionnaireValue;
  final bool disableSubmitButton;
  final void Function() onTapSubmit;
  final List<BookPreScreeningModel> questionnaires;

  @override
  State<BookPreScreeningScreenWidget> createState() =>
      _BookPreScreeningScreenWidgetState();
}

class _BookPreScreeningScreenWidgetState
    extends State<BookPreScreeningScreenWidget> {
  String _fileText = "";
  List<File> files = [];

  void removeFile(int index, String fileName) {
    if (index >= 0 && index < files.length) {
      setState(() {
        // String fileExtension = fileName.split('.').last;
        files.removeAt(index);
        _fileText = files.map((file) => file.path.split('/').last).join(', ');
        // print('Removed file with extension: $fileExtension');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<bool, String> options = {
      true: LocaleKeys.text_yes.tr(),
      false: LocaleKeys.text_no.tr(),
    };

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.customWidth(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < widget.questionnaires.length; i++)
                  QuestionnaireWidget(
                    value: widget.questionnaires[i].answer,
                    options: options,
                    onValueChanged: (value) {
                      widget.questionnaires[i].answer = value;
                      widget.onChangedQuestionnaireValue(i, value);
                    },
                    text: widget.questionnaires[i].question,
                    index: i,
                  ),
                Gap.h32,
                Text(
                  LocaleKeys.text_uploadYourFile.tr(),
                  style: TypographyTheme.textLRegular
                      .fontColor(BaseColor.neutral.shade60),
                ),
                Gap.h8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UploadFileWidget(
                      fileText: _fileText,
                      files: files,
                      onRemoveFile: removeFile,
                      onPickFiles: pickFiles,
                    ),
                    Gap.h8,
                  ],
                ),
                Gap.h8,
                Text(
                  "${LocaleKeys.text_supportedFileSize.tr()} : PDF, JPEG (Max 5MB)",
                  style: TypographyTheme.textSRegular
                      .fontColor(BaseColor.neutral.shade60),
                ),
                Gap.h16,
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: BaseSize.w20,
          ),
          child: ButtonWidget.primary(
            text: LocaleKeys.text_submit.tr(),
            buttonSize: ButtonSize.medium,
            onTap: widget.disableSubmitButton ? null : widget.onTapSubmit,
          ),
        ),
        Gap.h16,
      ],
    );
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg'],
    );

    if (result != null) {
      // files = result.paths.map((path) => File(path!)).toList();
      List<File> pickedFiles = result.paths.map((path) => File(path!)).toList();
      files.addAll(pickedFiles);
      print(files);
      setState(() {
        // _fileText = files.toString();
        _fileText = files.map((file) => file.path.split('/').last).join(', ');
      });
      print(_fileText);
    } else {
      // User canceled the picker
      print('User canceled file picking.');
    }
  }
}
