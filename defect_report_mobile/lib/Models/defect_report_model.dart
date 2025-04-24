class DefectReport {
  final int? reportId;
  final String reporter;
  final String reportDate;
  final int lineProdQty;
  final int sectionId;
  final int lineProductionId;
  final int defectId;
  final String? description;
  final int defectQty;
  final String sectionName;
  final String lineProductionName;
  final String defectName;
  final bool isNewDefect;
  final String? newDefectName;
  final int modelId;
  final String modelName;

  DefectReport({
    this.reportId,
    required this.reporter,
    required this.reportDate,
    required this.lineProdQty,
    required this.sectionId,
    required this.lineProductionId,
    required this.defectId,
    this.description,
    required this.defectQty,
    required this.sectionName,
    required this.lineProductionName,
    required this.defectName,
    this.isNewDefect = false,
    this.newDefectName,
    required this.modelId,
    required this.modelName,
  });

  factory DefectReport.fromJson(Map<String, dynamic> json) {
    return DefectReport(
      reportId: json['reportId'],
      reporter: json['reporter'],
      reportDate: json['reportDate']?.substring(0, 10) ?? '',
      lineProdQty: json['lineProdQty'] ?? 0,
      sectionId: json['section']?['sectionId'] ?? 0,
      lineProductionId: json['lineProduction']?['id'] ?? 0,
      defectId: json['defect']?['defectId'] ?? 0,
      description: json['description'],
      defectQty: json['defectQty'] ?? 0,
      sectionName: json['section']?['sectionName'] ?? '',
      lineProductionName: json['lineProduction']?['lineProductionName'] ?? '',
      defectName: json['defect']?['defectName'] ?? '',
      modelId: json['wpModel']?['modelId'] ?? 0,
      modelName: json['wpModel']?['modelName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (reportId != null) "reportId": reportId,
      "reporter": reporter,
      "reportDate": DateTime.parse(reportDate).toIso8601String(),
      "lineProdQty": lineProdQty,
      "sectionId": sectionId,
      "lineProductionId": lineProductionId,
      "defectId": defectId,
      "description": description,
      "defectQty": defectQty,
      "defectName": isNewDefect ? newDefectName : null,
      "modelId": modelId,
      "modelName": modelName,
    };
  }

  DefectReport copyWith({
    int? reportId,
    String? reporter,
    String? reportDate,
    int? lineProdQty,
    int? sectionId,
    int? lineProductionId,
    int? defectId,
    String? description,
    int? defectQty,
    String? sectionName,
    String? lineProductionName,
    String? defectName,
    bool? isNewDefect,
    String? newDefectName,
    int? modelId,
    String? modelName,
  }) {
    return DefectReport(
      reportId: reportId ?? this.reportId,
      reporter: reporter ?? this.reporter,
      reportDate: reportDate ?? this.reportDate,
      lineProdQty: lineProdQty ?? this.lineProdQty,
      sectionId: sectionId ?? this.sectionId,
      lineProductionId: lineProductionId ?? this.lineProductionId,
      defectId: defectId ?? this.defectId,
      description: description ?? this.description,
      defectQty: defectQty ?? this.defectQty,
      sectionName: sectionName ?? this.sectionName,
      lineProductionName: lineProductionName ?? this.lineProductionName,
      defectName: defectName ?? this.defectName,
      isNewDefect: isNewDefect ?? this.isNewDefect,
      newDefectName: newDefectName ?? this.newDefectName,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
    );
  }
}
