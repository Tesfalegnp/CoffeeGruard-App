import 'package:hive/hive.dart';

part 'recommendation_model.g.dart';

@HiveType(typeId: 2)
class RecommendationModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String diseaseLabel;

  @HiveField(2)
  String severity;

  @HiveField(3)
  String title;

  @HiveField(4)
  String content;

  @HiveField(5)
  String priority;

  @HiveField(6)
  DateTime? updatedAt;

  /// AMHARIC SUPPORT
  @HiveField(7)
  String? titleAm;

  @HiveField(8)
  String? contentAm;

  /// OROMO SUPPORT
  @HiveField(9)
  String? titleOm;

  @HiveField(10)
  String? contentOm;

  /// NEW: CATEGORY FIELD (added to match Supabase schema)
  @HiveField(11)
  String? category;

  RecommendationModel({
    required this.id,
    required this.diseaseLabel,
    required this.severity,
    required this.title,
    required this.content,
    required this.priority,
    this.updatedAt,
    this.titleAm,
    this.contentAm,
    this.titleOm,
    this.contentOm,
    this.category,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'].toString(),
      diseaseLabel: json['disease_label'] ?? '',
      severity: json['severity'] ?? 'medium',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      priority: json['priority'] ?? 'medium',
      updatedAt: json['updated_at'] != null 
          ? DateTime.tryParse(json['updated_at'].toString()) 
          : null,
      titleAm: json['title_am'],
      contentAm: json['content_am'],
      titleOm: json['title_om'],
      contentOm: json['content_om'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'disease_label': diseaseLabel,
      'severity': severity,
      'title': title,
      'content': content,
      'priority': priority,
      'updated_at': updatedAt?.toIso8601String(),
      'title_am': titleAm,
      'content_am': contentAm,
      'title_om': titleOm,
      'content_om': contentOm,
      'category': category,
    };
  }

  /// Helper method to get content based on language preference
  String getContentByLanguage(String languageCode) {
    switch (languageCode) {
      case 'am':
        return contentAm ?? content;
      case 'om':
        return contentOm ?? content;
      default:
        return content;
    }
  }

  /// Helper method to get title based on language preference
  String getTitleByLanguage(String languageCode) {
    switch (languageCode) {
      case 'am':
        return titleAm ?? title;
      case 'om':
        return titleOm ?? title;
      default:
        return title;
    }
  }
}