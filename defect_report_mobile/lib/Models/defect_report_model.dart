class DefectReport {
  final int? reportId;
  final String reporter;
  final String reportDate;
  final int prodQty;
  final int sectionId;
  final int lineProductionId;
  final int defectId;
  final String? description;
  final String status;
  final int defectQty;
  final String sectionName;
  final String lineProductionName;
  final String defectName;

  DefectReport({
    this.reportId,
    required this.reporter,
    required this.reportDate,
    required this.prodQty,
    required this.sectionId,
    required this.lineProductionId,
    required this.defectId,
    this.description,
    required this.status,
    required this.defectQty,
    required this.sectionName,
    required this.lineProductionName,
    required this.defectName,
  });

  factory DefectReport.fromJson(Map<String, dynamic> json) {
    return DefectReport(
      reportId: json['reportId'],
      reporter: json['reporter'],
      reportDate: json['reportDate']?.substring(0, 10) ?? '',
      prodQty: json['prodQty'] ?? 0,
      sectionId: json['section']?['sectionId'] ?? 0,
      lineProductionId: json['lineProduction']?['id'] ?? 0,
      defectId: json['defect']?['defectId'] ?? 0,
      description: json['description'],
      status: json['status'] ?? '',
      defectQty: json['defectQty'] ?? 0,
      sectionName: json['section']?['sectionName'] ?? '',
      lineProductionName: json['lineProduction']?['lineProductionName'] ?? '',
      defectName: json['defect']?['defectName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "reportId": reportId,
      "reporter": reporter,
      "reportDate": reportDate,
      "prodQty": prodQty,
      "sectionId": sectionId,
      "lineProductionId": lineProductionId,
      "defectId": defectId,
      "description": description,
      "status": status,
      "defectQty": defectQty,
    };
  }

  DefectReport copyWith({
    int? reportId,
    String? reporter,
    String? reportDate,
    int? prodQty,
    int? sectionId,
    int? lineProductionId,
    int? defectId,
    String? description,
    String? status,
    int? defectQty,
    String? sectionName,
    String? lineProductionName,
    String? defectName,
  }) {
    return DefectReport(
      reportId: reportId ?? this.reportId,
      reporter: reporter ?? this.reporter,
      reportDate: reportDate ?? this.reportDate,
      prodQty: prodQty ?? this.prodQty,
      sectionId: sectionId ?? this.sectionId,
      lineProductionId: lineProductionId ?? this.lineProductionId,
      defectId: defectId ?? this.defectId,
      description: description ?? this.description,
      status: status ?? this.status,
      defectQty: defectQty ?? this.defectQty,
      sectionName: sectionName ?? this.sectionName,
      lineProductionName: lineProductionName ?? this.lineProductionName,
      defectName: defectName ?? this.defectName,
    );
  }
}
