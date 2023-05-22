import 'package:flight_deck/utils/theme_utils.dart';

class UserSettings {
  const UserSettings({
    required this.theme,
  });

  final FlightDeckTheme theme;

  Map<String, dynamic> toJson() {
    return {
      "theme": theme.toDbCompatibleString(),
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      theme: FlightDeckTheme.fromDbCompatibleString(json["theme"] ?? ""),
    );
  }

  /// Can't use default because it's a keyword or something stupid
  factory UserSettings.empty() {
    return const UserSettings(
      theme: FlightDeckTheme.original,
    );
  }
}
