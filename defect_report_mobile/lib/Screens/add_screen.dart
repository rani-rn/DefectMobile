
import 'package:defect_report_mobile/Screens/Widget/defect_form.dart';
import 'package:flutter/material.dart';
class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Defect'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:DefectInputForm(), 
      ),
    );
  }
}