import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/poke_model.dart';

const restfulApi = 'https://pokeapi.co/api/v2/';

// Provider for managing Pokémon data
class PokemonProvider with ChangeNotifier {
  PokeModel? _pokeModel;
  PokeModel? get pokeModel => _pokeModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPokeList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('${restfulApi}pokemon?limit=10&offset=0'));
      if (response.statusCode == 200) {
        log(response.body);
        _pokeModel = PokeModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<PokeModel?> fetchPokemonData(String pokemonName) async {
    try {
      final response =
          await http.get(Uri.parse('$restfulApi/pokemon/$pokemonName'));
      if (response.statusCode == 200) {
        return PokeModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      log('Error: $e');
      return null;
    }
  }
}
