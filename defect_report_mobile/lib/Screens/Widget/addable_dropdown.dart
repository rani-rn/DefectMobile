import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class DefectDropdown extends StatelessWidget {
  final List<Map<String, dynamic>> defectList;
  final String? selectedDefect;
  final void Function(String?)? onChanged;
  final void Function(String)? onAddNew;

  const DefectDropdown({
    super.key,
    required this.defectList,
    required this.selectedDefect,
    required this.onChanged,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      selectedItem: selectedDefect,
      items:(String? filter,_ ) => defectList.map((e) => e['defectName'] as String).toList(),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          decoration: const InputDecoration(hintText: 'Search or add defect...'),
        ),
        emptyBuilder: (context, searchEntry) => ListTile(
          title: Text('Add "$searchEntry" as new defect'),
          leading: const Icon(Icons.add),
          onTap: () {
            Navigator.pop(context);
            onAddNew?.call(searchEntry);
          },
        ),
      ),
      dropdownBuilder: (context, selectedItem) =>
          Text(selectedItem ?? '', style: const TextStyle(fontSize: 14)),
      validator: (value) => value == null ? 'Required' : null,
      onChanged: onChanged,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'Defect',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
