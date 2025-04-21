class Section {
  final int sectionId;
  final String sectionName;
  final int sectionTotal;

  Section({
    required this.sectionId,
    required this.sectionName,
    required this.sectionTotal,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],
      sectionTotal: json['sectionTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'sectionName': sectionName,
      'sectionTotal': sectionTotal,
    };
  }
}
