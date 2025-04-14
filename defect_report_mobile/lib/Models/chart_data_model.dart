class DefectChartData {
  final String label;
  final int value;

  DefectChartData({required this.label, required this.value, required List<DefectChartData> data});

  factory DefectChartData.fromJson(Map<String, dynamic> json) {
    return DefectChartData(
      label: json['label'],
      value: json['value'], data: [],
    );
  }
}
