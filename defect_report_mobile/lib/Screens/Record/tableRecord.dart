import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Screens/Record/update_report.dart';
import 'package:defect_report_mobile/Screens/Widget/delete_confirm.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class DefectReportTable extends StatefulWidget {
  final List<DefectReport> reports;
  final VoidCallback onRefresh;

  const DefectReportTable({
    super.key,
    required this.reports,
    required this.onRefresh,
  });

  @override
  State<DefectReportTable> createState() => _DefectReportTableState();
}

class _DefectReportTableState extends State<DefectReportTable> {
  void _showActionSheet(BuildContext context, DefectReport report) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateScreen(report: report),
                  ),
                );
              },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(report);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(DefectReport report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const ConfirmDeleteDialog(),
    );

    if (confirm == true) {
      final success = await ApiServices.deleteReport(report.reportId!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report delete seccessfully')),
        );
        widget.onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report delete failed')),
        );
      }
    }
  }

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
        rows: widget.reports.asMap().entries.map((entry) {
          int index = entry.key + 1;
          final d = entry.value;
          return DataRow(
            cells: [
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
            ],
            onLongPress: () => _showActionSheet(context, d),
          );
        }).toList(),
      ),
    );
  }
}
