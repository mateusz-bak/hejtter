import 'package:flutter/material.dart';
import 'package:hejtter/services/hejto_api.dart';
import 'package:hejtter/utils/constants.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.postSlug,
    this.commentUUID,
  });

  final String postSlug;
  final String? commentUUID;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  int? _reasonSelected;
  String? _otherReason;
  bool _reportSending = false;
  bool remindThatOtherReasonCannotBeEmpty = false;

  _selectOption(int option) {
    if (option == _reasonSelected) {
      setState(() {
        _reasonSelected = null;
      });
    } else {
      setState(() {
        _reasonSelected = option;
      });
    }
  }

  _updateOtherReason(String otherReason) {
    if (otherReason.isNotEmpty) {
      _otherReason = otherReason;
      setState(() {
        remindThatOtherReasonCannotBeEmpty = false;
        _reasonSelected = 5;
      });
    } else {
      _otherReason = null;
    }
  }

  _sendReport() async {
    if (_reasonSelected == 5) {
      if (_otherReason == null || _otherReason!.isEmpty) {
        setState(() {
          remindThatOtherReasonCannotBeEmpty = true;
        });
        return;
      }
    }

    setState(() {
      _reportSending = true;
    });

    late bool result;

    if (widget.commentUUID == null) {
      result = await hejtoApi.createPostReport(
        context: context,
        slug: widget.postSlug,
        reason: _reasonSelected!,
        otherReasonDescription: _reasonSelected == 5 ? _otherReason! : null,
      );
    } else {
      result = await hejtoApi.createCommentReport(
        context: context,
        postSlug: widget.postSlug,
        commentUUID: widget.commentUUID!,
        reason: _reasonSelected!,
        otherReasonDescription: _reasonSelected == 5 ? _otherReason! : null,
      );
    }

    Navigator.of(context).pop();

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: widget.commentUUID != null
              ? const Text('Zgłoszono komentarz')
              : const Text('Zgłoszono wpis'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(width: 1, color: dividerColor)),
      contentPadding: const EdgeInsets.all(8),
      elevation: 0,
      backgroundColor: backgroundColor,
      title: widget.commentUUID != null
          ? const Text('Zgłoś komentarz')
          : const Text('Zgłoś wpis'),
      children: [
        ReportDialogOption(
          isSelected: _reasonSelected == 0,
          title: reportReasons[0],
          description: reportReasonDesc[0],
          option: 0,
          onSelected: _selectOption,
        ),
        ReportDialogOption(
          isSelected: _reasonSelected == 1,
          title: reportReasons[1],
          description: reportReasonDesc[1],
          option: 1,
          onSelected: _selectOption,
        ),
        ReportDialogOption(
          isSelected: _reasonSelected == 2,
          title: reportReasons[2],
          description: reportReasonDesc[2],
          option: 2,
          onSelected: _selectOption,
        ),
        ReportDialogOption(
          isSelected: _reasonSelected == 3,
          title: reportReasons[3],
          description: reportReasonDesc[3],
          option: 3,
          onSelected: _selectOption,
        ),
        ReportDialogOption(
          isSelected: _reasonSelected == 4,
          title: reportReasons[4],
          description: reportReasonDesc[4],
          option: 4,
          onSelected: _selectOption,
        ),
        ReportDialogOption(
          isSelected: _reasonSelected == 5,
          title: reportReasons[5],
          option: 5,
          onSelected: _selectOption,
          updateOtherReason: _updateOtherReason,
          reminder: remindThatOtherReasonCannotBeEmpty,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _reasonSelected != null ? _sendReport : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: onPrimaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(width: 1, color: dividerColor),
            ),
          ),
          child: _reportSending
              ? const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    color: boltColor,
                  ),
                )
              : const Text('Wyślij zgłoszenie'),
        ),
      ],
    );
  }
}

class ReportDialogOption extends StatelessWidget {
  const ReportDialogOption({
    super.key,
    required this.isSelected,
    required this.title,
    this.description,
    required this.onSelected,
    required this.option,
    this.updateOtherReason,
    this.reminder,
  });

  final bool isSelected;
  final String title;
  final String? description;
  final Function(int) onSelected;
  final Function(String)? updateOtherReason;
  final int option;
  final bool? reminder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Switch(
            value: isSelected,
            onChanged: (_) {
              onSelected(option);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(option),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  description != null
                      ? Text(description!)
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: backgroundSecondaryColor,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Scrollbar(
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              expands: false,
                              decoration: InputDecoration.collapsed(
                                  hintText: 'Wpisz treść...',
                                  hintStyle: TextStyle(
                                      color: reminder == true
                                          ? Colors.red
                                          : null)),
                              onChanged: (value) {
                                if (updateOtherReason != null) {
                                  updateOtherReason!(value);
                                }
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
