// class PokeModel {
//   final Map<String, dynamic> data;

//   PokeModel({required this.data});

//   factory PokeModel.fromJson(Map<String, dynamic> json) {
//     return PokeModel(data: json);
//   }
// }

class PokeModel {
  final List<Pokemon> results;

  PokeModel({required this.results});

  factory PokeModel.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<Pokemon> pokemonList = list.map((i) => Pokemon.fromJson(i)).toList();
    return PokeModel(results: pokemonList);
  }
}

class Pokemon {
  final String name;
  final String url;
  String? spriteUrl;
  List<String>? types;
  int? weight;

  Pokemon({
    required this.name,
    required this.url,
    this.spriteUrl,
    this.types,
    this.weight,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      url: json['url'],
    );
  }

  // This function will update details like sprites and types later
  void updateDetails(Map<String, dynamic> detailsJson) {
    spriteUrl =
        detailsJson['sprites']['other']?['official-artwork']?['front_default'];
    types = (detailsJson['types'] as List)
        .map((typeInfo) => typeInfo['type']['name'] as String)
        .toList();
    weight = detailsJson['weight'];
  }
}
