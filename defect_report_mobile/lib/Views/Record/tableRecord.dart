import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:flutter/material.dart';

class DefectReportTable extends StatelessWidget {
  final List<DefectReport> reports;
  const DefectReportTable({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10,
        columns: const [
          DataColumn(label: Text("No")),
          DataColumn(label: Text("Date")),
          DataColumn(label: Text("Prod Qty")),
          DataColumn(label: Text("Reporter")),
          DataColumn(label: Text("Section")),
          DataColumn(label: Text("Line")),
          DataColumn(label: Text("Defect")),
          DataColumn(label: Text("Description")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Defect Qty")),
        ],
        rows: reports.asMap().entries.map((entry) {
          int index = entry.key + 1;
          final d = entry.value;
          return DataRow(cells: [
            DataCell(Text('$index')),
            DataCell(Text(d.reportDate)),
            DataCell(Text('${d.prodQty}')),
            DataCell(Text(d.reporter)),
            DataCell(Text(d.sectionName)),
            DataCell(Text(d.lineProductionName)),
            DataCell(Text(d.defectName)),
            DataCell(Text(d.description ?? '-')),
            DataCell(Text(d.status)),
            DataCell(Text('${d.defectQty}')),
          ]);
        }).toList(),
      ),
    );
  }
}