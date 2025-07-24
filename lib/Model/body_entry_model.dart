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
    double? weight,
    double? fatPercentage,
    double? neckCircumference,
    double? waistCircumference,
    double? hipCircumference,
    List<String>? tags,
    String? notes,
    bool setFrontImagePathNull = false,
    String? frontImagePath,
    bool setSideImagePathNull = false,
    String? sideImagePath,
    bool setBackImagePathNull = false,
    String? backImagePath,
    double? bmi, // Added BMI parameter
  }) {
    return BodyEntry(
      date: date ?? this.date,
      weight: weight ?? this.weight,
      fatPercentage: fatPercentage ?? this.fatPercentage,
      neckCircumference: neckCircumference ?? this.neckCircumference,
      waistCircumference: waistCircumference ?? this.waistCircumference,
      hipCircumference: hipCircumference ?? this.hipCircumference,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      frontImagePath: setFrontImagePathNull ? null : (frontImagePath ?? this.frontImagePath),
      sideImagePath: setSideImagePathNull ? null : (sideImagePath ?? this.sideImagePath),
      backImagePath: setBackImagePathNull ? null : (backImagePath ?? this.backImagePath),
      bmi: bmi ?? this.bmi, // Added BMI field
    );
  }

  /// Converts a BodyEntry object to a map for database storage
  /// @return Map<String, dynamic> representing the BodyEntry object
  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'weight': weight,
      'fatPercentage': fatPercentage,
      'neckCircumference': neckCircumference,
      'waistCircumference': waistCircumference,
      'hipCircumference': hipCircumference,
      'tags': tags != null ? tags!.join(',') : null,
      'notes': notes,
      'frontImagePath': frontImagePath,
      'sideImagePath': sideImagePath,
      'backImagePath': backImagePath,
      'bmi': bmi, // Added BMI field
    };
  }

  /// Creates a BodyEntry object from a database map
  /// @param map The map containing the BodyEntry data
  /// @return BodyEntry object created from the map
  static BodyEntry fromMap(Map<String, dynamic> map) {
    return BodyEntry(
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      weight: map['weight'],
      fatPercentage: map['fatPercentage'],
      neckCircumference: map['neckCircumference'],
      waistCircumference: map['waistCircumference'],
      hipCircumference: map['hipCircumference'],
      tags: map['tags'] != null ? map['tags'].split(',') : null,
      notes: map['notes'],
      frontImagePath: map['frontImagePath'],
      sideImagePath: map['sideImagePath'],
      backImagePath: map['backImagePath'],
      bmi: map['bmi'], // Added BMI field
    );
  }
}
