class PokeData {
  final String url;
  final String name;
  final Map<String, dynamic> details;

  PokeData({
    required this.url,
    required this.name,
    required this.details,
  });

  // Factory constructor to create an instance of PokeData from a JSON object
  factory PokeData.fromJson(Map<String, dynamic> json) {
    return PokeData(
      url: json['url'],
      name: json['name'],
      details:
          json['details'] ?? {}, // Assign an empty map if 'details' is null
    );
  }

  // Method to update the details later
  void updateDetails(Map<String, dynamic> detailsJson) {
    details.addAll(detailsJson);
  }
}
