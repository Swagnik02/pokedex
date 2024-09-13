import 'package:flutter/material.dart';
import 'package:pokedex/extensions/string_casing_extension.dart';
import 'package:pokedex/extensions/type_colours.dart';
import 'package:pokedex/models/poke_model.dart';
import 'package:pokedex/screens/pokemon_data_page.dart'; // Import the package

Widget customPokemonTile(Pokemon pokemon, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDataPage(
            pokemonName: pokemon.name,
          ),
        ),
      );
    },
    child: Card(
      surfaceTintColor:
          typeColors[pokemon.types!.first.toLowerCase()] ?? Colors.grey,
      shadowColor: Colors.grey,
      child: Column(
        children: [
          pokemon.spriteUrl != null
              ? Image.network(
                  pokemon.spriteUrl!,
                  height: 100,
                )
              : const CircularProgressIndicator(),
          Text(
            pokemon.name.toCapitalized,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          pokemon.types != null
              ? Wrap(
                  spacing: 8.0,
                  children: pokemon.types!.map((type) {
                    return Chip(
                      label: Text(
                        type.toString().toCapitalized,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                          typeColors[type.toLowerCase()] ?? Colors.grey,
                    );
                  }).toList(),
                )
              : const Text('Loading...'),
        ],
      ),
    ),
  );
}
