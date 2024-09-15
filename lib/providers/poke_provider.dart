import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/poke_model.dart';

const restfulApi = 'https://pokeapi.co/api/v2/';

class PokemonProvider with ChangeNotifier {
  List<PokeData> _pokeList = [];
  List<PokeData> get pokeList => _pokeList;
  List<PokeData> _evolutionChain = [];
  List<PokeData> get evolutionChain => _evolutionChain;
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
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      log('Error fetching Pokémon details: $e');
      return null;
    }
  }

  PokeData? findPokemonByName(String name) {
    try {
      return _pokeList.firstWhere((pokemon) => pokemon.name == name);
    } catch (e) {
      return null;
    }
  }

  Future<void> findEvolutionChainUrl(String speciesChainUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(speciesChainUrl));
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        final evolutionChainUrl =
            decodedResponse['evolution_chain']['url'] as String;
        log('Evolution chain URL: $evolutionChainUrl');

        // Fetch the evolution chain details
        await fetchEvolutionChain(evolutionChainUrl);
      } else {
        throw Exception('Failed to load Pokémon details');
      }
    } catch (e) {
      log('Error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEvolutionChain(String evoChainUrl) async {
    _isLoading = true; // Ensure _isLoading is set to true when fetching data
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(evoChainUrl));
      if (response.statusCode == 200) {
        final decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        final chain = decodedResponse['chain'] as Map<String, dynamic>;

        // Start the recursive function from the base chain
        _evolutionChain.clear();
        await _logEvolutionChain(chain);
        log(_evolutionChain.map((poke) => poke.name).join(' -> '));
      } else {
        throw Exception('Failed to load evolution chain details');
      }
    } catch (e) {
      log('Error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading =
          false; // Ensure _isLoading is set to false when data fetching is complete
      notifyListeners();
    }
  }

  Future<void> _logEvolutionChain(Map<String, dynamic> chain) async {
    // Log the current species name
    String name = chain['species']['name'].toString();
    log(name);
    String url = '${restfulApi}pokemon/$name';
    log(url);

    final Map<String, dynamic>? details = await fetchPokemonDetails(url);

    // Check if details is not null before creating PokeData
    if (details != null) {
      var pokemon = PokeData(name: name, url: url, details: details);
      _evolutionChain.add(pokemon);
    } else {
      log('Failed to fetch details for $name');
    }

    // Check if there are further evolutions
    final evolvesTo = chain['evolves_to'] as List<dynamic>;
    for (var evolution in evolvesTo) {
      await _logEvolutionChain(evolution as Map<String, dynamic>);
    }
  }
}
