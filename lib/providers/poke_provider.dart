import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/poke_model.dart';

const restfulApi = 'https://pokeapi.co/api/v2/';

class PokemonProvider with ChangeNotifier {
  List<Pokemon> _pokeList = [];
  List<Pokemon> get pokeList => _pokeList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Fetch a list of Pokémon with details like sprites and types
  Future<void> fetchPokeList(int offset) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int limit = 6; // You can adjust the limit as per your requirement

    try {
      // Fetch list of basic Pokémon data (name and url)
      final response = await http
          .get(Uri.parse('${restfulApi}pokemon?limit=$limit&offset=$offset'));
      if (response.statusCode == 200) {
        // Parse the initial list of Pokémon
        final rawData = jsonDecode(response.body);
        PokeModel pokeModel = PokeModel.fromJson(rawData);

        // Clear the current list
        _pokeList = pokeModel.results;

        // Fetch additional data for each Pokémon in parallel
        for (Pokemon pokemon in _pokeList) {
          final details = await fetchPokemonData(pokemon.url);
          if (details != null) {
            pokemon.updateDetails(details);
          }
        }

        notifyListeners();
      } else {
        throw Exception('Failed to load Pokémon list');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Pokémon details like sprites, types, and weight
  Future<Map<String, dynamic>?> fetchPokemonData(String pokemonUrl) async {
    try {
      final response = await http.get(Uri.parse(pokemonUrl));
      if (response.statusCode == 200) {
        log(response.body);
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }
}
