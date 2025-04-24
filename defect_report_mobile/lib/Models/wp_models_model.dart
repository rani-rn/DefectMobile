class WpModels {
  final int modelId;
  final String modelName;

  WpModels({
    required this.modelId,
    required this.modelName,
  });

  factory WpModels.fromJson(Map<String, dynamic> json) {
    return WpModels(
      modelId: json['modelId'],
      modelName: json['modelName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modelId': modelId,
      'modelName': modelName,
    };
  }
}
