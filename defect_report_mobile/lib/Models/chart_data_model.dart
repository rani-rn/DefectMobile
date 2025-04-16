class DefectChartData {
  final String label;
  final int value;

  DefectChartData({required this.label, required this.value});

  factory DefectChartData.fromJson(Map<String, dynamic> json) {
    return DefectChartData(
      label: json['label'] as String,
      value: json['value'] as int,
    );
  }
}
