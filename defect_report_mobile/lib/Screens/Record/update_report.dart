import 'package:defect_report_mobile/Screens/Widget/defect_form.dart';
import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:flutter/material.dart';
class UpdateScreen extends StatefulWidget {
  final DefectReport report;
  const UpdateScreen({super.key, required this.report});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Defect'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefectInputForm(defectReportId: widget.report.reportId),
      ),
    );
  }
}
