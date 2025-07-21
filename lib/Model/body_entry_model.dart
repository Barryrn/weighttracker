class BodyEntry {
  final DateTime date;
  final double? weight;
  final double? fatPercentage;
  final double? neckCircumference;
  final double? waistCircumference;
  final double? hipCircumference;
  final List<String>? tags;
  final String? notes;
  final String? imagePath;

  BodyEntry({
    required this.date,
    this.weight,
    this.fatPercentage,
    this.neckCircumference,
    this.waistCircumference,
    this.hipCircumference,
    this.tags,
    this.notes,
    this.imagePath,
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
  /// @param imagePath The new image path value (optional)
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
    String? imagePath,
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
      imagePath: imagePath ?? this.imagePath,
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
      'imagePath': imagePath,
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
      imagePath: map['imagePath'],
    );
  }
}
