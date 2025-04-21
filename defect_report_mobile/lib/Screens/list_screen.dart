import 'package:defect_report_mobile/Screens/Record/tableRecord.dart';
import 'package:flutter/material.dart';
import '../Models/defect_report_model.dart';
import '../Services/api_services.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  State<RecordListScreen> createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  late Future<List<DefectReport>> _futureReports;
  String _searchTerm = "";

  @override
  void initState() {
    super.initState();
    _futureReports = ApiServices.getDefectReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Defect Records")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchTerm = value.toLowerCase());
              },
            ),
            const SizedBox(height: 10),
               Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Tombol Export to Excel ditekan');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5, 
                  ),
                  child: const Text('Export to Excel'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DefectReport>>(
                future: _futureReports,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final filtered = snapshot.data!
                        .where((d) =>
                            d.reporter.toLowerCase().contains(_searchTerm) ||
                            (d.sectionName.toLowerCase())
                                .contains(_searchTerm) ||
                            (d.lineProductionName.toLowerCase() )
                                .contains(_searchTerm) ||
                            (d.defectName.toLowerCase() )
                                .contains(_searchTerm))
                        .toList();

                    return DefectReportTable(reports: filtered, onRefresh: () {  },);
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
