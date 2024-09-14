import 'package:flutter/material.dart';
import 'package:pokedex/models/poke_model.dart';
import 'package:pokedex/extensions/type_colours.dart';
import 'package:pokedex/screens/pokemon_data_page.dart';

Widget customPokemonTile(PokeData pokedata, BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PokemonDataPage(
            pokemonName: pokedata.name,
          ),
        ),
      );
    },
    child: Card(
      surfaceTintColor: typeColors[
              pokedata.details['types']?[0]['type']['name'].toLowerCase()] ??
          Colors.grey,
      shadowColor: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '#${pokedata.details['id']}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  pokedata.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (pokedata.details['types'] != null)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokedata.details['types'].map<Widget>((type) {
                      return Chip(
                        padding: const EdgeInsets.all(0),
                        elevation: 1,
                        label: Text(
                          type['type']['name'],
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            typeColors[type['type']['name'].toLowerCase()] ??
                                Colors.grey,
                      );
                    }).toList(),
                  ),
                Hero(
                  tag: pokedata.name,
                  child: pokedata.details['sprites']?['front_default'] != null
                      ? Image.network(
                          pokedata.details['sprites']['front_default'],
                          height: 100,
                        )
                      : const CircularProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
