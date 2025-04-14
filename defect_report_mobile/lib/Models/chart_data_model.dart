class ChartDataItem {
  final String label;
  final int value;

  ChartDataItem({required this.label, required this.value});

  factory ChartDataItem.fromJson(Map<String, dynamic> json) {
    return ChartDataItem(
      label: json['label'],
      value: json['value'],
    );
  }
}

class ChartDataResponse {
  final List<ChartDataItem> chartData;
  final int daily;
  final int weekly;
  final int monthly;

  ChartDataResponse({
    required this.chartData,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory ChartDataResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['chartData'] as List)
        .map((item) => ChartDataItem.fromJson(item))
        .toList();
    return ChartDataResponse(
      chartData: list,
      daily: json['daily'],
      weekly: json['weekly'],
      monthly: json['monthly'],
    );
  }
}
