import 'package:defect_report_mobile/Models/chart_data_model.dart';
import 'package:defect_report_mobile/Screens/Dashboard/box_widgets.dart';
import 'package:defect_report_mobile/Screens/Dashboard/breakdown.dart';
import 'package:defect_report_mobile/Screens/Dashboard/defect_chart.dart';
import 'package:defect_report_mobile/Services/api_services.dart';
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  String selectedPeriod = 'daily';
  late Future<DefectChartResponse> futureData;
  String? selectedLabel;
  String? selectedLine;
  List<Map<String, dynamic>> breakdownData = [];

  @override
  void initState() {
    super.initState();
    futureData = ApiServices.fetchChartData(selectedPeriod);
  }

  void _onPeriodChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedPeriod = value;
        futureData = ApiServices.fetchChartData(selectedPeriod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = (screenWidth - 60) / 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: FutureBuilder<DefectChartResponse>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading dashboard'));
              } else if (snapshot.hasData) {
                final chartData = snapshot.data!;

                final summaryValues = {
                  'daily': chartData.summary.today,
                  'weekly': chartData.summary.week,
                  'monthly': chartData.summary.month,
                };

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: DropdownButtonFormField<String>(
                          value: selectedPeriod,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(12),
                            labelText: "Filter by Time",
                            border: OutlineInputBorder(),
                          ),
                          items: ['daily', 'weekly', 'monthly'].map((e) {
                            return DropdownMenuItem(
                              value: e,
                              child: Text(e.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: _onPeriodChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: summaryValues.entries.map((entry) {
                            return Container(
                              width: itemWidth,
                              margin: const EdgeInsets.only(right: 12),
                              child: SummaryBox(
                                title: entry.key,
                                value: entry.value,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 500,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DefectChart(
                          data: chartData,
                          onBarTapped: (String label, String? line) async {
                            final response = await ApiServices.fetchBreakdown(
                                selectedPeriod, label, line!);
                            setState(() {
                              selectedLabel = label;
                              selectedLine = line;
                              breakdownData = response;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // BreakdownCard(
                      //   label: selectedLabel,
                      //   lineProduction: selectedLine,
                      //   breakdownData: breakdownData,
                      // ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }
}
