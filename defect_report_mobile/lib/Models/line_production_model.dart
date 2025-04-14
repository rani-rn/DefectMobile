class LineProduction {
  final int id;
  final String lineProductionName;

  LineProduction({
    required this.id,
    required this.lineProductionName,
  });

  factory LineProduction.fromJson(Map<String, dynamic> json) {
    return LineProduction(
      id: json['id'],
      lineProductionName: json['lineProductionName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lineProductionName': lineProductionName,
    };
  }
}
