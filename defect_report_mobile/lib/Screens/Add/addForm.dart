import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DefectInputForm extends StatefulWidget {
  @override
  _DefectInputFormState createState() => _DefectInputFormState();
}

class _DefectInputFormState extends State<DefectInputForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _productionQtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _defectQtyController = TextEditingController();

  String? _selectedSection;
  String? _selectedLineProduction;
  String? _selectedDefect;
  String? _selectedStatus;
  String? _selectedRole;

  List<Map<String, dynamic>> _defectItems = [
    {'id': 1, 'name': 'Crack'},
    {'id': 2, 'name': 'Scratch'},
  ];

  InputDecoration formInput({required String label}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 14),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Future<void> _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse('https://your-api-url.com/api/DefectReports'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reporter': _reporterController.text,
          'reportDate': _dateController.text,
          'prodQty': int.tryParse(_productionQtyController.text) ?? 0,
          'section': _selectedSection,
          'lineProduction': _selectedLineProduction,
          'defect': _selectedDefect,
          'description': _descriptionController.text,
          'status': _selectedStatus,
          'defectQty': int.tryParse(_defectQtyController.text) ?? 0,
          'role': _selectedRole,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Defect Report saved successfully!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save defect report.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _reporterController,
                    decoration: formInput(label: 'Reporter'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          decoration: formInput(label: 'Date'),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: formInput(label: 'Role'),
                          items: ['Operator', 'QA'].map((role) {
                            return DropdownMenuItem(value: role, child: Text(role));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedRole = val),
                          validator: (value) => value == null ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLineProduction,
                    decoration: formInput(label: 'Line Production'),
                    items: ['Line 1', 'Line 2'].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedLineProduction = val),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedDefect,
                    decoration: formInput(label: 'Defect Record'),
                    items: _defectItems.map((defect) {
                      return DropdownMenuItem(
                        value: defect['id'].toString(),
                        child: Text(defect['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDefect = val),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: formInput(label: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: formInput(label: 'Status'),
                    items: ['Repairable', 'Dispose'].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _productionQtyController,
                    decoration: formInput(label: 'Production Qty'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _defectQtyController,
                    decoration: formInput(label: 'Defect Qty'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Save', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
