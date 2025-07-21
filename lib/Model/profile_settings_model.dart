/// A model class that represents the user's profile settings.
///
/// This class follows the MVVM pattern by acting as the Model that stores
/// the data related to user profile settings.
class ProfileSettings {
  /// The user's birthday.
  final DateTime? birthday;
  
  /// The user's gender (e.g., 'Male', 'Female', 'Other').
  final String? gender;
  
  /// The user's height in centimeters.
  final double? height;

  /// Creates a ProfileSettings instance.
  ///
  /// All parameters are optional and default to null.
  const ProfileSettings({
    this.birthday,
    this.gender,
    this.height,
  });

  /// Creates a copy of this ProfileSettings with the given fields replaced with new values.
  ///
  /// This method is used to update the profile settings while maintaining immutability.
  ProfileSettings copyWith({
    DateTime? birthday,
    String? gender,
    double? height,
  }) {
    return ProfileSettings(
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      height: height ?? this.height,
    );
  }

  /// Converts this ProfileSettings to a map.
  ///
  /// This method is useful for serializing the profile settings to JSON
  /// or storing them in a database.
  Map<String, dynamic> toMap() {
    return {
      'birthday': birthday?.millisecondsSinceEpoch,
      'gender': gender,
      'height': height,
    };
  }

  /// Creates a ProfileSettings from a map.
  ///
  /// This method is useful for deserializing the profile settings from JSON
  /// or retrieving them from a database.
  factory ProfileSettings.fromMap(Map<String, dynamic> map) {
    return ProfileSettings(
      birthday: map['birthday'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthday'])
          : null,
      gender: map['gender'],
      height: map['height'],
    );
  }
}