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
      items: (String? filter, _) {
        final List<String> defects =
            defectList.map((e) => e['defectName'] as String).toList();
        return [...defects, 'ADD_NEW|$filter'];
      },
      filterFn: (item, filter) {
        final itemName =
            item.startsWith('ADD_NEW|') ? item.split('|').last : item;
        if (filter.isEmpty) return true;
        return itemName.toLowerCase().contains(filter.toLowerCase());
      },
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          decoration:
              const InputDecoration(hintText: 'Search or add defect...'),
        ),
        itemBuilder: (context, item, isDisabled, isSelected) {
          if (item.startsWith('ADD_NEW|')) {
            final searchText = item.split('|').last;
            return ListTile(
              title: Text('Add new defect: $searchText'),
              leading: const Icon(Icons.add),
              tileColor: isSelected ? Colors.grey[200] : null,
            );
          }
          return ListTile(
            title: Text(item),
            selected: isSelected,
            tileColor: isSelected ? Colors.grey[200] : null,
          );
        },
      ),
      dropdownBuilder: (context, selectedItem) {
        if (selectedItem == null || selectedItem.startsWith('ADD_NEW|')) {
          return const Text('', style: TextStyle(fontSize: 14));
        }
        return Text(selectedItem, style: const TextStyle(fontSize: 14));
      },
      validator: (value) => value == null ? 'Required' : null,
      onChanged: (value) {
        if (value?.startsWith('ADD_NEW|') ?? false) {
          final query = value!.split('|').last;
          onAddNew?.call(query);
        } else {
          onChanged?.call(value);
        }
      },
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
