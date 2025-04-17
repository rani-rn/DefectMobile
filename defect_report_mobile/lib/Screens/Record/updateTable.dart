import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DefectEditForm extends StatefulWidget {
  final int reportId;

  const DefectEditForm({super.key, required this.reportId});

  @override
  State<DefectEditForm> createState() => _DefectEditFormState();
}

class _DefectEditFormState extends State<DefectEditForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reporterController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _productionQtyController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _defectQtyController = TextEditingController();

  String? _selectedSection;
  String? _selectedLineProduction;
  String? _selectedDefect;
  late int reportId;

  late Future<Map<String, dynamic>> _dropdownDataFuture;
  late Future<Map<String, dynamic>> _formDataFuture;

  List<Map<String, dynamic>> sections = [];
  List<Map<String, dynamic>> lineProductions = [];
  List<Map<String, dynamic>> defects = [];

  @override
  void initState() {
    super.initState();
    _dropdownDataFuture = ApiServices.getDropdownData();
    _formDataFuture = ApiServices.getReportById(reportId);
  }

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

  void _setInitialData(Map<String, dynamic> data) {
    _reporterController.text = data['reporter'] ?? '';
    _dateController.text = data['date'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _productionQtyController.text = data['productionQty'].toString();
    _defectQtyController.text = data['defectQty'].toString();
    _selectedSection = data['sectionId'].toString();
    _selectedLineProduction = data['lineProductionId'].toString();
    _selectedDefect = data['defectId'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dropdownDataFuture,
          builder: (context, dropdownSnapshot) {
            if (dropdownSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (dropdownSnapshot.hasError) {
              return Center(child: Text('Error: ${dropdownSnapshot.error}'));
            } else if (dropdownSnapshot.hasData) {
              final dropdownData = dropdownSnapshot.data!;
              lineProductions =
                  List<Map<String, dynamic>>.from(dropdownData['lineProductions']);
              sections = List<Map<String, dynamic>>.from(dropdownData['sections']);
              defects = List<Map<String, dynamic>>.from(dropdownData['defects']);

              return FutureBuilder<Map<String, dynamic>>(
                future: _formDataFuture,
                builder: (context, formSnapshot) {
                  if (formSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (formSnapshot.hasError) {
                    return Center(child: Text('Error: ${formSnapshot.error}'));
                  } else if (formSnapshot.hasData) {
                    final formData = formSnapshot.data!;
                    _setInitialData(formData);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _reporterController,
                              decoration: formInput(label: 'Reporter'),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: formInput(label: 'Date'),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (pickedDate != null) {
                                  String formattedDate =
                                      "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                  setState(() {
                                    _dateController.text = formattedDate;
                                  });
                                }
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedLineProduction,
                              decoration: formInput(label: 'Line Production'),
                              items: lineProductions.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['id'].toString(),
                                  child: Text(item['lineProductionName']),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedLineProduction = val),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedSection,
                              decoration: formInput(label: 'Section'),
                              items: sections.map((item) {
                                return DropdownMenuItem<String>(
                                  value: item['sectionId'].toString(),
                                  child: Text(item['sectionName']),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedSection = val),
                              validator: (value) =>
                                  value == null ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            DropdownSearch<String>(
                              selectedItem: defects.firstWhere(
                                  (d) => d['defectId'].toString() == _selectedDefect,
                                  orElse: () => {'defectName': ''})['defectName'],
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration:
                                    formInput(label: 'Defect Record'),
                              ),
                              asyncItems: (String filter) async {
                                return defects
                                    .map((defect) =>
                                        defect['defectName'].toString())
                                    .where((name) => name
                                        .toLowerCase()
                                        .contains(filter.toLowerCase()))
                                    .toList();
                              },
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                              ),
                              onChanged: (val) {
                                final defect = defects.firstWhere(
                                    (d) => d['defectName'] == val,
                                    orElse: () => {});
                                setState(() {
                                  if (defect.isNotEmpty) {
                                    _selectedDefect =
                                        defect['defectId'].toString();
                                  } else {
                                    _selectedDefect = 'new:$val';
                                  }
                                });
                              },
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: formInput(label: 'Description'),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _productionQtyController,
                              keyboardType: TextInputType.number,
                              decoration: formInput(label: 'Production Qty'),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _defectQtyController,
                              keyboardType: TextInputType.number,
                              decoration: formInput(label: 'Defect Qty'),
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Submit updated data
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Update',
                                      style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: Text("No form data available"));
                  }
                },
              );
            } else {
              return const Center(child: Text("No dropdown data"));
            }
          },
        ),
      ),
    );
  }
}
