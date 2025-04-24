import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> _exportToExcel() async {
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

  // for (int i = 0; i < widget.reports.length; i++) {
  //   final r = widget.reports[i];
  //   sheet.appendRow([
  //     i + 1,
  //     r.reportDate,
  //     r.prodQty,
  //     r.reporter,
  //     r.sectionName,
  //     r.lineProductionName,
  //     r.defectName,
  //     r.description ?? '-',
  //     r.status,
  //     r.defectQty
  //   ]);
  // }

  // var status = await Permission.storage.request();
  // if (!status.isGranted) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Storage permission denied')),
  //   );
  //   return;
  // }

  final dir = await getExternalStorageDirectory();
  final file = File('${dir!.path}/DefectReports.xlsx');
  await file.writeAsBytes(excel.encode()!);

  // ScaffoldMessenger.of(context).showSnackBar(
  //   SnackBar(content: Text('Exported to ${file.path}')),
  // );
}
