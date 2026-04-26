class SystemSettingsModel {
  bool autoApprove;
  double confidenceThreshold;
  bool requireExpertReview;
  bool offlineMode;
  bool autoSync;
  String language;

  SystemSettingsModel({
    this.autoApprove = false,
    this.confidenceThreshold = 0.7,
    this.requireExpertReview = true,
    this.offlineMode = false,
    this.autoSync = true,
    this.language = "en",
  });

  Map<String, dynamic> toMap() {
    return {
      "autoApprove": autoApprove,
      "confidenceThreshold": confidenceThreshold,
      "requireExpertReview": requireExpertReview,
      "offlineMode": offlineMode,
      "autoSync": autoSync,
      "language": language,
    };
  }

  factory SystemSettingsModel.fromMap(Map data) {
    return SystemSettingsModel(
      autoApprove: data["autoApprove"] ?? false,
      confidenceThreshold: data["confidenceThreshold"] ?? 0.7,
      requireExpertReview: data["requireExpertReview"] ?? true,
      offlineMode: data["offlineMode"] ?? false,
      autoSync: data["autoSync"] ?? true,
      language: data["language"] ?? "en",
    );
  }
}