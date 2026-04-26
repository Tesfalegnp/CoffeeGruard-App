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

  RecommendationModel({
    required this.id,
    required this.diseaseLabel,
    required this.severity,
    required this.title,
    required this.content,
    required this.priority,
    this.updatedAt,
  });
}