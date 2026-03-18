import 'package:hive/hive.dart';

part 'detection_result_model.g.dart';

@HiveType(typeId: 0)
class DetectionResultModel extends HiveObject {

  /// Unique ID for the detection
  @HiveField(0)
  String id;

  /// Local path where image is stored
  @HiveField(1)
  String? imageLocalPath;

  /// Image URL after upload to Supabase
  @HiveField(2)
  String? imageUrl;

  /// First level detection result
  @HiveField(3)
  bool isCoffeeLeaf;

  /// Confidence for leaf detection
  @HiveField(4)
  double? leafConfidence;

  /// Disease label (Rust / Healthy)
  @HiveField(5)
  String? diseaseLabel;

  /// Disease confidence score
  @HiveField(6)
  double? diseaseConfidence;

  /// Recommendation text
  @HiveField(7)
  String? recommendation;

  /// Creation timestamp
  @HiveField(8)
  DateTime createdAt;

  /// Sync status
  @HiveField(9)
  bool isSynced;

  /// 🌍 NEW: Latitude
  @HiveField(10)
  double? latitude;

  /// 🌍 NEW: Longitude
  @HiveField(11)
  double? longitude;

  DetectionResultModel({
    required this.id,
    this.imageLocalPath,
    this.imageUrl,
    required this.isCoffeeLeaf,
    this.leafConfidence,
    this.diseaseLabel,
    this.diseaseConfidence,
    this.recommendation,
    required this.createdAt,
    this.isSynced = false,
    this.latitude,
    this.longitude,
  });
}