import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _productionQtyController =TextEditingController();
  final TextEditingController _defectController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _defectQtyController = TextEditingController();

  String? _selectedSection;
  String? _selectedLineProduction;
  String? _selectedDefect;
  String? _selectedStatus;
  List<Map<String, dynamic>> _defectItems = [];

  @override
  void initState() {
    super.initState();
    // _fetchDefectItems();
  }

  // Future<void> _fetchDefectItems() async {
  //   final response = await http.get(Uri.parse('https://your-api-url.com/api/DefectItems'));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       _defectItems = List<Map<String, dynamic>>.from(json.decode(response.body));
  //     });
  //   }
  // }

  // Custom input decoration for TextFormField
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

  Future<void> _saveData() async {
    if (_formKey.currentState?.validate() ?? false) {
      final response = await http.post(
        Uri.parse(
            'https://your-api-url.com/api/DefectReports'), // Replace with your actual API endpoint
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
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Defect Report saved successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save defect report.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  initialDate: DateTime.now(),
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
                  setState(() => _selectedSection = newValue as String?),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: _selectedLineProduction,
              decoration: customInputDecoration(label: 'Line Production'),
              items: ['Line 1', 'Line 2'].map((String value) {
                return DropdownMenuItem(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) =>
                  setState(() => _selectedLineProduction = newValue as String?),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: _selectedDefect,
              decoration: customInputDecoration(label: 'Defect Item'),
              items: _defectItems.map((defect) {
                return DropdownMenuItem(
                  value: defect['id'].toString(),
                  child: Text(defect['name']),
                );
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
                  onPressed: _saveData,
                  child: const Text('Save'),
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
    );
  }
}
