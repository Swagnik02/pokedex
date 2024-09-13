class PokeModel {
  final Map<String, dynamic> data;

  PokeModel({required this.data});

  factory PokeModel.fromJson(Map<String, dynamic> json) {
    return PokeModel(data: json);
  }
}
