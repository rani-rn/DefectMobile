import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class DefectInputForm extends StatefulWidget {
  final int? defectReportId;

  const DefectInputForm({Key? key, this.defectReportId}) : super(key: key);

  @override
  State<DefectInputForm> createState() => _DefectInputFormState();
}

class _DefectInputFormState extends State<DefectInputForm> {
  final _formKey = GlobalKey<FormState>();
  final _reporterController = TextEditingController();
  final _dateController = TextEditingController();
  final _productionQtyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _defectQtyController = TextEditingController();

  String? _selectedSection;
  String? _selectedLineProduction;
  String? _selectedDefect;
  String? _selectedStatus;

  late Future<Map<String, dynamic>> _dropdownDataFuture;
  Future<Map<String, dynamic>>? _editDataFuture;
  List<Map<String, dynamic>> _defectList = [];
  List<String> status = [];

  @override
  void initState() {
    super.initState();
    _dropdownDataFuture = ApiServices.getDropdownData();

    if (widget.defectReportId != null) {
      _editDataFuture = ApiServices.getReportById(widget.defectReportId!);
    }
    status = ['Repairable', 'Dispose'];
  }

  void _populateFields(Map<String, dynamic> data) {
    _reporterController.text = data['reporter'] ?? '';
    _dateController.text =
        data['reportDate']?.toString().substring(0, 10) ?? '';
    _productionQtyController.text = data['prodQty']?.toString() ?? '';
    _descriptionController.text = data['description'] ?? '';
    _defectQtyController.text = data['defectQty']?.toString() ?? '';
    _selectedSection = data['section']?['sectionName'];
    _selectedLineProduction = data['lineProduction']?['lineProductionName'];
    _selectedDefect = data['defect']?['defectName'];
    _selectedStatus = data['status'];
  }

  void _addNewDefect(String newDefect) {
    setState(() {
      if (!_defectList.any((d) => d['defectName'] == newDefect)) {
        _defectList.add({'defectName': newDefect});
      }
      _selectedDefect = newDefect;
    });
  }

  void _clearForm() {
    _reporterController.clear();
    _dateController.clear();
    _productionQtyController.clear();
    _descriptionController.clear();
    _defectQtyController.clear();

    setState(() {
      _selectedSection = null;
      _selectedLineProduction = null;
      _selectedDefect = null;
      _selectedStatus = null;
    });
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        fillColor: Colors.white,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      );

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? inputType,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: _inputDecoration(label),
        keyboardType: inputType,
        validator: validator ??
            (value) => value == null || value.isEmpty ? 'Required' : null,
        onTap: onTap,
        maxLines: maxLines,
      );

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? selectedItem,
    required void Function(String?) onChanged,
  }) =>
      DropdownSearch<String>(
        selectedItem: selectedItem,
        items: (String? filter, _) => items,
        popupProps: PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(hintText: 'Search $label...'),
          ),
        ),
        decoratorProps:
            DropDownDecoratorProps(decoration: _inputDecoration(label)),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      );

  Widget _buildDefectDropdown() {
    return DropdownSearch<String>(
      selectedItem: _selectedDefect,
      items: (String? filter, _) =>
          _defectList.map((e) => e['defectName'] as String).toList(),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          decoration:
              const InputDecoration(hintText: 'Search or add defect...'),
        ),
        emptyBuilder: (context, searchEntry) => ListTile(
          title: Text('Add "$searchEntry" as new defect'),
          leading: const Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            _addNewDefect(searchEntry);
          },
        ),
      ),
      dropdownBuilder: (context, selectedItem) =>
          Text(selectedItem ?? '', style: const TextStyle(fontSize: 14)),
      decoratorProps:
          DropDownDecoratorProps(decoration: _inputDecoration('Defect')),
      onChanged: (val) => setState(() => _selectedDefect = val),
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildForm(List<Map<String, dynamic>> sections,
      List<Map<String, dynamic>> lines, List<Map<String, dynamic>> defects) {
    _defectList = defects;
    final sectionNames =
        sections.map((e) => e['sectionName'] as String).toList();
    final lineNames =
        lines.map((e) => e['lineProductionName'] as String).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(_reporterController, 'Reporter'),
            const SizedBox(height: 12),
            _buildTextField(
              _dateController,
              'Date',
              readOnly: true,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  final date =
                      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  setState(() => _dateController.text = date);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(_productionQtyController, 'Production Qty',
                inputType: TextInputType.number),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Section',
              items: sectionNames,
              selectedItem: _selectedSection,
              onChanged: (val) => setState(() => _selectedSection = val),
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              label: 'Line Production',
              items: lineNames,
              selectedItem: _selectedLineProduction,
              onChanged: (val) => setState(() => _selectedLineProduction = val),
            ),
            const SizedBox(height: 12),
            _buildDefectDropdown(),
            const SizedBox(height: 12),
            _buildTextField(
              _descriptionController,
              'Description',
              maxLines: 3,
              validator: (value) => null,
            ),
            const SizedBox(height: 12),
            _buildTextField(_defectQtyController, 'Defect Qty',
                inputType: TextInputType.number),
            const SizedBox(height: 20),
            _buildDropdown(
              label: 'Status',
              items: status,
              selectedItem: _selectedStatus,
              onChanged: (val) => setState(() => _selectedStatus = val),
            ),
            const SizedBox(height: 12),
            _buildButton('Save', Colors.green, () async {
              if (_formKey.currentState!.validate()) {
                final sectionId =
                    _findIdByName(sections, 'sectionName', _selectedSection);
                final lineId = _findIdByName(
                    lines, 'lineProductionName', _selectedLineProduction);
                final defectId =
                    _findIdByName(defects, 'defectName', _selectedDefect);

                final report = DefectReport(
                  reportId: widget.defectReportId,
                  reporter: _reporterController.text,
                  reportDate: _dateController.text,
                  prodQty: int.tryParse(_productionQtyController.text) ?? 0,
                  sectionId: sectionId ?? 0,
                  lineProductionId: lineId ?? 0,
                  defectId: defectId ?? 0,
                  description: _descriptionController.text,
                  status: _selectedStatus!,
                  defectQty: int.tryParse(_defectQtyController.text) ?? 0,
                  sectionName: _selectedSection!,
                  lineProductionName: _selectedLineProduction!,
                  defectName: _selectedDefect!,
                );

                bool success;
                if (widget.defectReportId == null) {
                  success = await ApiServices.addDefectReport(report);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Report added successfully')),
                    );
                  }
                } else {
                  success = await ApiServices.updateDefectReport(report);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Report updated successfully')),
                    );
                  }
                }

                if (success) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong')),
                  );
                }
              }
            }),
            const SizedBox(height: 10),
            _buildButton('Cancel', Colors.red, _clearForm),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
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
              final sections =
                  List<Map<String, dynamic>>.from(dropdownData['sections']);
              final lines = List<Map<String, dynamic>>.from(
                  dropdownData['lineProductions']);
              final defects =
                  List<Map<String, dynamic>>.from(dropdownData['defects']);

              if (_editDataFuture != null) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: _editDataFuture,
                  builder: (context, editSnapshot) {
                    if (editSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (editSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${editSnapshot.error}'));
                    } else if (editSnapshot.hasData) {
                      _populateFields(editSnapshot.data!);
                      return _buildForm(sections, lines, defects);
                    }
                    return const Center(child: Text('Failed to load data'));
                  },
                );
              } else {
                return _buildForm(sections, lines, defects);
              }
            } else {
              return const Center(child: Text('No dropdown data available'));
            }
          },
        ),
      ),
    );
  }
}

int? _findIdByName(List<Map<String, dynamic>> list, String key, String? value) {
  if (value == null) return null;
  final match = list.firstWhere(
    (element) => element[key] == value,
    orElse: () => {},
  );
  return match['id'];
}
