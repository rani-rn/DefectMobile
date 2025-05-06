import 'package:defect_report_mobile/Screens/Record/table_record.dart';
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
  int _currentPage = 0;
  final int _rowsPerPage = 15;

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

            Expanded(
              child: FutureBuilder<List<DefectReport>>(
                future: _futureReports,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final filtered = snapshot.data!
                        .where((d) {
                          final matchSearch = d.reporter.toLowerCase().contains(_searchTerm) ||
                              d.modelName.toLowerCase().contains(_searchTerm) ||
                              d.sectionName.toLowerCase().contains(_searchTerm) ||
                              d.lineProductionName.toLowerCase().contains(_searchTerm) ||
                              d.defectName.toLowerCase().contains(_searchTerm);

                          return matchSearch;
                        })
                        .toList();

                    final pagedReports = filtered.skip(_currentPage * _rowsPerPage).take(_rowsPerPage).toList();

                    return Column(
                      children: [
                        DefectReportTable(reports: pagedReports, onRefresh: () {  }),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: _currentPage > 0
                                  ? () => setState(() => _currentPage--)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text("Page ${_currentPage + 1}"),
                            IconButton(
                              onPressed: (_currentPage + 1) * _rowsPerPage < filtered.length
                                  ? () => setState(() => _currentPage++)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    );
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
