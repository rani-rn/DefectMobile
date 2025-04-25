import 'dart:io';
import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> exportToExcel(BuildContext context, List<DefectReport> reports) async {
  final excel = Excel.createExcel();
  final sheet = excel['Defect Reports'];

  sheet.appendRow([
    TextCellValue('No'),
    TextCellValue('Date'),
    TextCellValue('Reporter'),
    TextCellValue('Model'),
    TextCellValue('Section'),
    TextCellValue('Line'),
    TextCellValue('Line Prod Qty'),
    TextCellValue('Defect'),
    TextCellValue('Description'),
    TextCellValue('Defect Qty'),
  ]);

  for (int i = 0; i < reports.length; i++) {
    final d = reports[i];
    sheet.appendRow([
      TextCellValue('${i + 1}'),
      TextCellValue(d.reportDate),
      TextCellValue(d.reporter),
      TextCellValue(d.modelName),
      TextCellValue(d.sectionName),
      TextCellValue(d.lineProductionName),
      TextCellValue(d.lineProdQty.toString()),
      TextCellValue(d.defectName),
      TextCellValue(d.description ?? '-'),
      TextCellValue(d.defectQty.toString()),
    ]);
  }

  final status = await Permission.storage.request();
  if (status.isGranted) {
    final directory = await getExternalStorageDirectory();
    final path = "${directory!.path}/DefectReports.xlsx";
    final fileBytes = excel.encode();

    if (fileBytes != null) {
       File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

     
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel file saved at: $path')),
        );
    }
  } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied')),
      );
  }
}
