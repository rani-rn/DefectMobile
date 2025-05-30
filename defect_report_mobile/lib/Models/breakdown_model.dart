class BreakdownItem {
  final String lineProduction;
  final List<DefectCount> topDefects;

  BreakdownItem({required this.lineProduction, required this.topDefects});

  factory BreakdownItem.fromJson(Map<String, dynamic> json) {
    return BreakdownItem(
      lineProduction: json['lineProduction'],
      topDefects: (json['topDefects'] as List)
          .map((e) => DefectCount.fromJson(e))
          .toList(),
    );
  }
}

class DefectCount {
  final String defect;
  final int qty;

  DefectCount({required this.defect, required this.qty});

  factory DefectCount.fromJson(Map<String, dynamic> json) {
    return DefectCount(
      defect: json['defect'],
      qty: json['qty'],
    );
  }
}
