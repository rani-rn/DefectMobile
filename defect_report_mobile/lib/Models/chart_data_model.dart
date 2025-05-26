class DefectDataset {
  final String label;
  final List<int> data;
  final String backgroundColor;

  DefectDataset({required this.label, required this.data, required this.backgroundColor});

  factory DefectDataset.fromJson(Map<String, dynamic> json) {
    return DefectDataset(
      label: json['label'],
      data: List<int>.from(json['data']),
      backgroundColor: json['backgroundColor'],
    );
  }
}

class DefectChartResponse {
  final List<String> labels;
  final List<DefectDataset> datasets;
  final int daily, weekly, monthly, annual;

  DefectChartResponse({
    required this.labels,
    required this.datasets,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.annual,
  });

  factory DefectChartResponse.fromJson(Map<String, dynamic> json) {
    return DefectChartResponse(
      labels: List<String>.from(json['labels']),
      datasets: (json['datasets'] as List)
          .map((e) => DefectDataset.fromJson(e))
          .toList(),
      daily: json['daily'],
      weekly: json['weekly'],
      monthly: json['monthly'],
      annual: json['annual'],
    );
  }
}
