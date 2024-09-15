class PokeData {
  final String url;
  final String name;
  final Map<String, dynamic> details;

  PokeData({
    required this.url,
    required this.name,
    required this.details,
  });

  factory PokeData.fromJson(Map<String, dynamic> json) {
    return PokeData(
      url: json['url'] ?? '', // Provide a default empty string if null
      name: json['name'] ?? '', // Provide a default empty string if null
      details: json['details'] ?? {}, // Provide an empty map if null
    );
  }

  // Method to update the details later
  void updateDetails(Map<String, dynamic> detailsJson) {
    details.addAll(detailsJson);
  }
}
