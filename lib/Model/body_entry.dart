class BodyEntry {
  final double weight; 
  final DateTime date; 
  final double? fatPercentage;
  final BodyMeasurements? measurements;
  final List<String>? tags;
  final String? notes;
  final String? imagePath;

  BodyEntry({
    required this.weight,
    required this.date,
    this.fatPercentage,
    this.measurements,
    this.tags,
    this.notes,
    this.imagePath,
  });
  
  /// Converts a BodyEntry object to a map for database storage
  /// @return Map<String, dynamic> representing the BodyEntry object
  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'date': date.millisecondsSinceEpoch,
      'fatPercentage': fatPercentage,
      'measurements': measurements?.toMap(),
      'tags': tags != null ? tags!.join(',') : null,
      'notes': notes,
      'imagePath': imagePath,
    };
  }
  
  /// Creates a BodyEntry object from a database map
  /// @param map The map containing the BodyEntry data
  /// @return BodyEntry object created from the map
  static BodyEntry fromMap(Map<String, dynamic> map) {
    return BodyEntry(
      weight: map['weight'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      fatPercentage: map['fatPercentage'],
      measurements: map['measurements'] != null 
          ? BodyMeasurements.fromMap(map['measurements']) 
          : null,
      tags: map['tags'] != null ? map['tags'].split(',') : null,
      notes: map['notes'],
      imagePath: map['imagePath'],
    );
  }
}

class BodyMeasurements {
  final double? neckCircumference; 
  final double? waistCircumference; 
  final double? hipCircumference;  

  BodyMeasurements({
    this.neckCircumference,
    this.waistCircumference,
    this.hipCircumference,
  });
  
  /// Converts a BodyMeasurements object to a map for database storage
  /// @return Map<String, dynamic> representing the BodyMeasurements object
  Map<String, dynamic> toMap() {
    return {
      'neckCircumference': neckCircumference,
      'waistCircumference': waistCircumference,
      'hipCircumference': hipCircumference,
    };
  }
  
  /// Creates a BodyMeasurements object from a database map
  /// @param map The map containing the BodyMeasurements data
  /// @return BodyMeasurements object created from the map
  static BodyMeasurements fromMap(Map<String, dynamic> map) {
    return BodyMeasurements(
      neckCircumference: map['neckCircumference'],
      waistCircumference: map['waistCircumference'],
      hipCircumference: map['hipCircumference'],
    );
  }
}
