// Add this at the top of your file, outside the class
const _sentinel = Object();

class BodyEntry {
  final DateTime date;
  final double? weight;
  final double? fatPercentage;
  final double? neckCircumference;
  final double? waistCircumference;
  final double? hipCircumference;
  final List<String>? tags;
  final String? notes;
  final String? frontImagePath;
  final String? sideImagePath;
  final String? backImagePath;
  final double? bmi; // Added BMI field
  final double? calorie;

  BodyEntry({
    required this.date,
    this.weight,
    this.fatPercentage,
    this.neckCircumference,
    this.waistCircumference,
    this.hipCircumference,
    this.tags,
    this.notes,
    this.frontImagePath,
    this.sideImagePath,
    this.backImagePath,
    this.bmi, // Added BMI parameter
    this.calorie,
  });

  /// Creates a copy of this BodyEntry with the given fields replaced with new values
  /// @param date The new date value (optional)
  /// @param weight The new weight value (optional)
  /// @param fatPercentage The new fat percentage value (optional)
  /// @param neckCircumference The new neck circumference value (optional)
  /// @param waistCircumference The new waist circumference value (optional)
  /// @param hipCircumference The new hip circumference value (optional)
  /// @param tags The new tags value (optional)
  /// @param notes The new notes value (optional)
  /// @param frontImagePath The new image path value (optional)
  /// @param bmi The new BMI value (optional)
  /// @return A new BodyEntry instance with the updated values
  BodyEntry copyWith({
    DateTime? date,
    Object? weight = _sentinel,
    Object? fatPercentage = _sentinel,
    Object? neckCircumference = _sentinel,
    Object? waistCircumference = _sentinel,
    Object? hipCircumference = _sentinel,
    Object? tags = _sentinel,
    Object? notes = _sentinel,
    bool setFrontImagePathNull = false,
    String? frontImagePath,
    bool setSideImagePathNull = false,
    String? sideImagePath,
    bool setBackImagePathNull = false,
    String? backImagePath,
    Object? bmi = _sentinel,
    Object? calorie = _sentinel,
  }) {
    return BodyEntry(
      date: date ?? this.date,
      weight: weight == _sentinel ? this.weight : weight as double?,
      fatPercentage: fatPercentage == _sentinel ? this.fatPercentage : fatPercentage as double?,
      neckCircumference: neckCircumference == _sentinel ? this.neckCircumference : neckCircumference as double?,
      waistCircumference: waistCircumference == _sentinel ? this.waistCircumference : waistCircumference as double?,
      hipCircumference: hipCircumference == _sentinel ? this.hipCircumference : hipCircumference as double?,
      tags: tags == _sentinel ? this.tags : tags as List<String>?,
      notes: notes == _sentinel ? this.notes : notes as String?,
      frontImagePath: setFrontImagePathNull
          ? null
          : (frontImagePath ?? this.frontImagePath),
      sideImagePath: setSideImagePathNull
          ? null
          : (sideImagePath ?? this.sideImagePath),
      backImagePath: setBackImagePathNull
          ? null
          : (backImagePath ?? this.backImagePath),
      bmi: bmi == _sentinel ? this.bmi : bmi as double?,
      calorie: calorie == _sentinel ? this.calorie : calorie as double?,
    );
  }

  /// Converts a BodyEntry object to a map for database storage
  /// @return Map<String, dynamic> representing the BodyEntry object
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'fat_percentage': fatPercentage,
      'neck_circumference': neckCircumference,
      'waist_circumference': waistCircumference,
      'hip_circumference': hipCircumference,
      'tags': tags != null ? tags!.join(',') : null,
      'notes': notes,
      'front_image_path': frontImagePath, // Changed to snake_case
      'side_image_path': sideImagePath, // Changed to snake_case
      'back_image_path': backImagePath, // Changed to snake_case
      'bmi': bmi,
      'calorie': calorie,
    };
  }

  /// Creates a BodyEntry object from a database map
  /// @param map The map containing the BodyEntry data
  /// @return BodyEntry object created from the map
  static BodyEntry fromMap(Map<String, dynamic> map) {
    return BodyEntry(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight'],
      fatPercentage: map['fat_percentage'],
      neckCircumference: map['neck_circumference'],
      waistCircumference: map['waist_circumference'],
      hipCircumference: map['hip_circumference'],
      tags: map['tags'] != null ? map['tags'].split(',') : null,
      notes: map['notes'],
      frontImagePath: map['front_image_path'], // Changed to snake_case
      sideImagePath: map['side_image_path'], // Changed to snake_case
      backImagePath: map['back_image_path'], // Changed to snake_case
      bmi: map['bmi'],
      calorie: map['calorie'],
    );
  }

  @override
  String toString() {
    return 'BodyEntry(date: ${date.toIso8601String()}, weight: $weight, fatPercentage: $fatPercentage, calorie: $calorie)';
  }
}


/// Represents a single progress image with its metadata
class ProgressImageEntry {
  final DateTime date;
  final double? weight;
  final String imagePath;
  final String viewType; // 'front', 'side', or 'back'
  final List<String>? tags;

  ProgressImageEntry({
    required this.date,
    required this.imagePath,
    required this.viewType,
    this.weight,
    this.tags,
  });

  /// Creates a ProgressImageEntry from a BodyEntry and image type
  static ProgressImageEntry? fromBodyEntry(BodyEntry entry, String viewType) {
    String? imagePath;
    
    switch (viewType.toLowerCase()) {
      case 'front':
        imagePath = entry.frontImagePath;
        break;
      case 'side':
        imagePath = entry.sideImagePath;
        break;
      case 'back':
        imagePath = entry.backImagePath;
        break;
    }

    if (imagePath == null) return null;

    return ProgressImageEntry(
      date: entry.date,
      weight: entry.weight,
      imagePath: imagePath,
      viewType: viewType.toLowerCase(),
      tags: entry.tags,
    );
  }
}
