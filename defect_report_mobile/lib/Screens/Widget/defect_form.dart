import 'package:defect_report_mobile/Models/defect_report_model.dart';
import 'package:defect_report_mobile/Screens/Widget/addable_dropdown.dart';
import 'package:defect_report_mobile/Screens/Widget/custom_button.dart';
import 'package:defect_report_mobile/Screens/Widget/custom_dropdown.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class DefectInputForm extends StatefulWidget {
  final int? defectReportId;

  const DefectInputForm({super.key, this.defectReportId});

  @override
  State<DefectInputForm> createState() => _DefectInputFormState();
}

class _DefectInputFormState extends State<DefectInputForm> {
  static final _formKey = GlobalKey<FormState>();
  static final _reporterController = TextEditingController();
  static final _dateController = TextEditingController();
  static final _productionQtyController = TextEditingController();
  static final _descriptionController = TextEditingController();
  static final _defectQtyController = TextEditingController();

  static String? _selectedSection;
  static String? _selectedLineProduction;
  static String? _selectedModel;
  static String? _selectedDefect;

  late Future<Map<String, dynamic>> _dropdownDataFuture;
  Future<Map<String, dynamic>>? _editDataFuture;
  List<Map<String, dynamic>> _defectList = [];

  bool _isPopulated = false;

  @override
  void initState() {
    super.initState();
    _dropdownDataFuture = ApiServices.getDropdownData();

    if (widget.defectReportId != null) {
      _editDataFuture = ApiServices.getReportById(widget.defectReportId!);
    } else {
    _clearForm(); 
  }
  }

  void _populateFields(Map<String, dynamic> data) {
    setState(() {
      _reporterController.text = data['reporter'] ?? '';
      _dateController.text =
          data['reportDate']?.toString().substring(0, 10) ?? '';
      _selectedModel = data['wpModel']?['modelName'];
      _descriptionController.text = data['description'] ?? '';
      _defectQtyController.text = data['defectQty']?.toString() ?? '';
      _selectedSection = data['section']?['sectionName'];
      _selectedLineProduction = data['lineProduction']?['lineProductionName'];
      _productionQtyController.text = data['lineProdQty']?.toString() ?? '';
      _selectedDefect = data['defect']?['defectName'];
    });
  }

  void _addNewDefect(String newDefect) {
    setState(() {
      if (!_defectList.any((d) => d['defectName'] == newDefect)) {
        _defectList.add({'defectName': newDefect, 'id': 0});
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
      _selectedModel = null;
    });
  }

  Future<void> _saveReport({
    required List<Map<String, dynamic>> sections,
    required List<Map<String, dynamic>> lines,
    required List<Map<String, dynamic>> defects,
    required List<Map<String, dynamic>> models,
  }) async {
    if (!_formKey.currentState!.validate()) return;

    final sectionId =
        _findIdByName(sections, 'sectionName', _selectedSection, 'sectionId');
    final lineId = _findIdByName(
        lines, 'lineProductionName', _selectedLineProduction, 'id');
    int? defectId =
        _findIdByName(defects, 'defectName', _selectedDefect, 'defectId');
    final modelId =
        _findIdByName(models, 'modelName', _selectedModel, 'modelId');

    if (defectId == null &&
        _selectedDefect != null &&
        _selectedDefect!.isNotEmpty) {
      try {
        defectId = await ApiServices.addDefect(_selectedDefect!);
        setState(() {
          defects.add({'defectName': _selectedDefect, 'defectId': defectId});
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add defect')),
        );
        return;
      }
    }

    final report = DefectReport(
      reportId: widget.defectReportId,
      reporter: _reporterController.text,
      reportDate: _dateController.text,
      lineProdQty: int.tryParse(_productionQtyController.text) ?? 0,
      sectionId: sectionId ?? 0,
      lineProductionId: lineId ?? 0,
      defectId: defectId ?? 0,
      description: _descriptionController.text,
      defectQty: int.tryParse(_defectQtyController.text) ?? 0,
      sectionName: _selectedSection!,
      lineProductionName: _selectedLineProduction!,
      defectName: _selectedDefect!,
      modelId: modelId ?? 0,
      modelName: _selectedModel ?? '',
    );

    bool success;
    if (widget.defectReportId == null) {
      success = await ApiServices.addDefectReport(report);
    } else {
      success = await ApiServices.updateDefectReport(report);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.defectReportId == null
              ? 'Report added successfully'
              : 'Report updated successfully'),
        ),
      );

      if (widget.defectReportId == null) {
        setState(() {
          _productionQtyController.clear();
          _selectedDefect = null;
          _descriptionController.clear();
          _defectQtyController.clear();
        });
      } else {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
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

  Widget _buildForm(
      List<Map<String, dynamic>> sections,
      List<Map<String, dynamic>> lines,
      List<Map<String, dynamic>> defects,
      List<Map<String, dynamic>> models) {
    _defectList = defects;
    final sectionNames =
        sections.map((e) => e['sectionName'] as String).toList();
    final lineNames =
        lines.map((e) => e['lineProductionName'] as String).toList();
    final modelNames = models.map((e) => e['modelName'] as String).toList();

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
            CustomDropdown(
              label: 'Model',
              items: modelNames,
              selectedItem: _selectedModel,
              onChanged: (val) => setState(() => _selectedModel = val),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              label: 'Section',
              items: sectionNames,
              selectedItem: _selectedSection,
              onChanged: (val) => setState(() => _selectedSection = val),
            ),
            const SizedBox(height: 12),
            CustomDropdown(
              label: 'Line Production',
              items: lineNames,
              selectedItem: _selectedLineProduction,
              onChanged: (val) => setState(() => _selectedLineProduction = val),
            ),
            const SizedBox(height: 12),
            _buildTextField(_productionQtyController, 'Line Production Qty',
                inputType: TextInputType.number),
            const SizedBox(height: 12),
            DefectDropdown(
              defectList: _defectList,
              selectedDefect: _selectedDefect,
              onChanged: (val) => setState(() => _selectedDefect = val),
              onAddNew: _addNewDefect,
            ),
            const SizedBox(height: 12),
            _buildTextField(_descriptionController, 'Description',
                maxLines: 3, validator: (value) => null),
            const SizedBox(height: 12),
            _buildTextField(_defectQtyController, 'Defect Qty',
                inputType: TextInputType.number),
            const SizedBox(height: 12),
            BuildButton('Save', Colors.green, () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Save'),
                  content: const Text('Are you sure you want to save?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                _saveReport(
                  sections: sections,
                  lines: lines,
                  defects: defects,
                  models: models,
                );
              }
            }),
            const SizedBox(height: 10),
            BuildButton('Cancel', Colors.red, () async {
              final confirmCancel = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Cancel'),
                  content: const Text(
                      'Your data will not be saved. Are you sure you want to cancel?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (confirmCancel == true) {
                if (widget.defectReportId != null) {
                  Navigator.pop(context);
                } else {
                  _clearForm();
                }
              }
            }),
          ],
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
            }

            if (dropdownSnapshot.hasError) {
              return Center(child: Text('Error: ${dropdownSnapshot.error}'));
            }

            if (dropdownSnapshot.hasData) {
              final dropdownData = dropdownSnapshot.data!;
              final sections =
                  List<Map<String, dynamic>>.from(dropdownData['sections']);
              final lines = List<Map<String, dynamic>>.from(
                  dropdownData['lineProductions']);
              final defects =
                  List<Map<String, dynamic>>.from(dropdownData['defects']);
              final models =
                  List<Map<String, dynamic>>.from(dropdownData['models']);

              if (_editDataFuture != null) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: _editDataFuture,
                  builder: (context, editSnapshot) {
                    if (editSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (editSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${editSnapshot.error}'));
                    }

                    if (editSnapshot.hasData) {
                      if (!_isPopulated) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _populateFields(editSnapshot.data!);
                          setState(() {
                            _isPopulated = true;
                          });
                        });
                      }

                      return _buildForm(sections, lines, defects, models);
                    }

                    return const Center(child: Text('Failed to load data'));
                  },
                );
              } else {
                return _buildForm(sections, lines, defects, models);
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

int? _findIdByName(
  List<Map<String, dynamic>> list,
  String key,
  String? name,
  String idKey,
) {
  if (name == null) return null;
  try {
    return list.firstWhere((item) =>
        (item[key] as String).trim().toLowerCase() ==
        name.trim().toLowerCase())[idKey] as int;
  } catch (_) {
    return null;
  }
}
