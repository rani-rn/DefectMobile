class Defect {
  final int defectId;
  final String defectName;
  final int? sectionId;

  Defect({
    required this.defectId,
    required this.defectName,
    this.sectionId,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      defectId: json['defectId'],
      defectName: json['defectName'],
      sectionId: json['sectionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defectId': defectId,
      'defectName': defectName,
      'sectionId': sectionId,
    };
  }
}
