import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DefectInputForm extends StatefulWidget {
  @override
  _DefectInputFormState createState() => _DefectInputFormState();
}

class _DefectInputFormState extends State<DefectInputForm> {
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
  late Future<Map<String, dynamic>> _dropdownDataFuture;

  @override
  void initState() {
    super.initState();
    _dropdownDataFuture = ApiServices
        .getDropdownData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dropdownDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final dropdownData = snapshot.data!;
              final lineProductions = List<Map<String, dynamic>>.from(
                  dropdownData['lineProductions']);
              final sections =
                  List<Map<String, dynamic>>.from(dropdownData['sections']);
              final defects =
                  List<Map<String, dynamic>>.from(dropdownData['defects']);

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _reporterController,
                        decoration: formInput(label: 'Reporter'),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: formInput(label: 'Date'),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Required'
                                      : null,
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
                            ),
                          ),
                        ],
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
                        validator: (value) => value == null ? 'Required' : null,
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
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDefect,
                        decoration: formInput(label: 'Defect Record'),
                        items: defects.map<DropdownMenuItem<String>>((defect) {
                          return DropdownMenuItem<String>(
                            value: defect['defectId'].toString(),
                            child: Text(defect['defectName']),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedDefect = val),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: formInput(label: 'Description'),
                      ),
                      const SizedBox(height: 12),
                      DropdownSearch<String>(
                        selectedItem: _selectedDefect,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration:
                              formInput(label: 'Defect Record'),
                        ),
                        asyncItems: (String filter) async {
                          return defects
                              .map((defect) => defect['defectName'].toString())
                              .where((name) => name
                                  .toLowerCase()
                                  .contains(filter.toLowerCase()))
                              .toList();
                        },
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search or type to add...',
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          final defect = defects.firstWhere(
                            (d) => d['defectName'] == val,
                            orElse: () => {},
                          );
                          setState(() {
                            if (defect != null) {
                              _selectedDefect = defect['defectId'].toString();
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
                        controller: _productionQtyController,
                        decoration: formInput(label: 'Production Qty'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _defectQtyController,
                        decoration: formInput(label: 'Defect Qty'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Simpan data
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child:
                                Text('Cancel', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }
}
