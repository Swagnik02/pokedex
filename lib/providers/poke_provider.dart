import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/poke_model.dart';

const restfulApi = 'https://pokeapi.co/api/v2/';

class PokemonProvider with ChangeNotifier {
  List<PokeData> _pokeList = [];
  List<PokeData> get pokeList => _pokeList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Fetch a list of Pokémon with details
  Future<void> fetchPokeList(int offset) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int limit = 6;

    try {
      // Fetch list of basic Pokémon data (name and url)
      final response = await http
          .get(Uri.parse('${restfulApi}pokemon?limit=$limit&offset=$offset'));
      if (response.statusCode == 200) {
        // Parse the initial list of Pokémon
        final rawData = jsonDecode(response.body);
        List<PokeData> fetchedPokeList = (rawData['results'] as List)
            .map((pokemonJson) => PokeData.fromJson(pokemonJson))
            .toList();

        _pokeList = fetchedPokeList;

        // Fetch additional data for each Pokémon concurrently
        List<Future<void>> fetchDetailsTasks = _pokeList.map((pokeData) async {
          final details = await fetchPokemonDetails(pokeData.url);
          if (details != null) {
            pokeData.updateDetails(details);
          }
        }).toList();

        // Wait for all details fetch tasks to complete
        await Future.wait(fetchDetailsTasks);

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
  Future<Map<String, dynamic>?> fetchPokemonDetails(String pokemonUrl) async {
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

  PokeData? findPokemonByName(String name) {
    try {
      return _pokeList.firstWhere((pokemon) => pokemon.name == name);
    } catch (e) {
      return null; // If the Pokémon is not found
    }
  }
}
