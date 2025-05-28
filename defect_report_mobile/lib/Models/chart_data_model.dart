class Dataset {
  final String label;
  final List<int> data;
  final String backgroundColor;

  Dataset({required this.label, required this.data, required this.backgroundColor});

  factory Dataset.fromJson(Map<String, dynamic> json) => Dataset(
    label: json['label'],
    data: List<int>.from(json['data']),
    backgroundColor: json['backgroundColor'],
  );
}

class DefectChartResponse {
  final List<String> labels;
  final List<Dataset> datasets;
  final Summary summary;

  DefectChartResponse({
    required this.labels,
    required this.datasets,
    required this.summary,
  });

  factory DefectChartResponse.fromJson(Map<String, dynamic> json) => DefectChartResponse(
    labels: List<String>.from(json['labels']),
    datasets: (json['datasets'] as List).map((e) => Dataset.fromJson(e)).toList(),
    summary: Summary.fromJson(json['summary']),
  );
}

class Summary {
  final int today;
  final int week;
  final int month;

  Summary({required this.today, required this.week, required this.month});

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    today: json['today'],
    week: json['week'],
    month: json['month'],
  );
}
