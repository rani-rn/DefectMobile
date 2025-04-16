import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UpdateTableScreen extends StatefulWidget {
  final DefectReport report;
  const UpdateTableScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<UpdateTableScreen> createState() => _UpdateTableScreenState();
}

class _UpdateTableScreenState extends State<UpdateTableScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reporterController;
  late TextEditingController _dateController;
  late TextEditingController _productionQtyController;
  late TextEditingController _descriptionController;
  late TextEditingController _defectQtyController;

  String? _selectedSection;
  String? _selectedLineProduction;
  String? _selectedDefect;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final r = widget.report;
    _reporterController = TextEditingController(text: r.reporter);
    _dateController = TextEditingController(text: r.reportDate);
    _productionQtyController = TextEditingController(text: r.prodQty.toString());
    _descriptionController = TextEditingController(text: r.description ?? '');
    _defectQtyController = TextEditingController(text: r.defectQty.toString());

    _selectedSection = r.sectionName;
    _selectedLineProduction = r.lineProductionName;
    _selectedDefect = r.defectName;
    _selectedStatus = r.status;
  }

  InputDecoration customInputDecoration({required String label, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: Color(0xFF0072BC)),
      hintStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0072BC)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF0072BC), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _updateData() async {
    if (_formKey.currentState!.validate()) {
      final updatedReport = widget.report.copyWith(
        reporter: _reporterController.text,
        reportDate: _dateController.text,
        prodQty: int.tryParse(_productionQtyController.text) ?? 0,
        sectionName: _selectedSection,
        lineProductionName: _selectedLineProduction,
        defectName: _selectedDefect,
        status: _selectedStatus,
        description: _descriptionController.text,
        defectQty: int.tryParse(_defectQtyController.text) ?? 0,
      );

      bool success = await ApiServices.updateDefectReport(updatedReport);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update report")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Defect Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _reporterController,
                decoration: customInputDecoration(label: 'Reporter'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration:
                    customInputDecoration(label: 'Date', hint: 'YYYY-MM-DD'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    String formattedDate =
                        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                    setState(() {
                      _dateController.text = formattedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _productionQtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: customInputDecoration(
                    label: 'Production Quantity', hint: 'Input Total Production'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedSection,
                decoration: customInputDecoration(label: 'Section'),
                items: ['Section A', 'Section B'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedSection = newValue),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedLineProduction,
                decoration: customInputDecoration(label: 'Line Production'),
                items: ['Line 1', 'Line 2'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedLineProduction = newValue),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedDefect,
                decoration: customInputDecoration(label: 'Defect Item'),
                items: ['Defect A', 'Defect B'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedDefect = newValue as String?),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: customInputDecoration(label: 'Description'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField(
                value: _selectedStatus,
                decoration: customInputDecoration(label: 'Status'),
                items: ['Repairable', 'Dispose'].map((String value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (newValue) =>
                    setState(() => _selectedStatus = newValue as String?),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _defectQtyController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: customInputDecoration(
                    label: 'Defect Quantity', hint: 'Jumlah defect ditemukan'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _updateData,
                    child: const Text('Update'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
