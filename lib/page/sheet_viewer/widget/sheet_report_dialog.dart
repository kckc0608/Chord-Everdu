import 'package:chord_everdu/page/common_widget/common_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SheetReportDialog extends StatefulWidget {
  final String sheetID;
  const SheetReportDialog({super.key, required this.sheetID});

  @override
  State<SheetReportDialog> createState() => _SheetReportDialogState();
}

enum ReportReasonType { badSheet }
class _SheetReportDialogState extends State<SheetReportDialog> {
  ReportReasonType reason = ReportReasonType.badSheet;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("악보 신고"),
      contentPadding: const EdgeInsets.all(0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile(
            title: const Text("잘못되었거나 의미없는 악보"),
            value: ReportReasonType.badSheet,
            groupValue: reason,
            onChanged: (value) {
              setState(() {
                reason = value!;
              });},
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: const Text("취소")),
        ElevatedButton(onPressed: () {
          User? reporter = FirebaseAuth.instance.currentUser;
          FirebaseFirestore.instance.collection('report_list').add({
            "sheet_id": widget.sheetID,
            "reporter": reporter == null ? "not login" : reporter.email,
            "report_time": FieldValue.serverTimestamp(),
            "reason": reason.name,
          }).then((value) {
            Logger().i("신고가 접수되었습니다.");
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => const CommonAlertDialog(content: "신고가 완료되었습니다."),
            );
          }, onError: (e) => Logger().e(e));
        }, child: const Text("신고")),
      ],
    );
  }
}
