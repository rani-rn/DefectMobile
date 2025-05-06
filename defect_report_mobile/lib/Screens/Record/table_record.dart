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
  bool _isSortByDate = false;
  // DateTime? _selectedDate;

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

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report deleted successfully')),
        );
        widget.onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report delete failed')),
        );
      }
    }
  }

  // Future<void> _pickDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null && picked != _selectedDate) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    List<DefectReport> displayedReports = List.from(widget.reports);
    if (_isSortByDate) {
      displayedReports.sort((a, b) =>
          DateTime.parse(b.reportDate).compareTo(DateTime.parse(a.reportDate)));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 10,
        columns: [
          const DataColumn(label: Text("No")),
          DataColumn(
            label: Row(
              children: [
                const Text("Date"),
                IconButton(
                  icon: const Icon(Icons.sort),
                  iconSize: 18,
                  onPressed: () {
                    setState(() {
                      _isSortByDate = !_isSortByDate;
                    });
                  },
                ),
              ],
            ),
          ),
          const DataColumn(label: Text("Reporter")),
          const DataColumn(label: Text("Model")),
          const DataColumn(label: Text("Section")),
          const DataColumn(label: Text("Line")),
          const DataColumn(label: Text("Line Prod Qty")),
          const DataColumn(label: Text("Defect")),
          const DataColumn(label: Text("Description")),
          const DataColumn(label: Text("Defect Qty")),
        ],
        rows: displayedReports.asMap().entries.map((entry) {
          int index = entry.key + 1;
          final d = entry.value;
          return DataRow(
            cells: [
              DataCell(Text('$index')),
              DataCell(Text(d.reportDate)),
              DataCell(Text(d.reporter)),
              DataCell(Text(d.modelName)),
              DataCell(Text(d.sectionName)),
              DataCell(Text(d.lineProductionName)),
              DataCell(Text('${d.lineProdQty}')),
              DataCell(Text(d.defectName)),
              DataCell(Text(d.description ?? '-')),
              DataCell(Text('${d.defectQty}')),
            ],
            onLongPress: () => _showActionSheet(context, d),
          );
        }).toList(),
      ),
    );
  }
}
