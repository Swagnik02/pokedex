import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokedex/models/poke_model.dart';
import 'package:pokedex/providers/poke_provider.dart';
import 'package:provider/provider.dart';

class PokemonDataPage extends StatelessWidget {
  final String pokemonName;
  // final Image imageViewer;

  const PokemonDataPage({
    super.key,
    required this.pokemonName,
    // required this.imageViewer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemonName)),
      body: FutureBuilder<PokeData?>(
        // Instead of fetching from the API, we fetch the specific Pokemon from the list
        future: Future.delayed(Duration.zero, () {
          // This delay ensures the UI doesn't update synchronously.
          return Provider.of<PokemonProvider>(context, listen: false)
              .findPokemonByName(pokemonName);
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pokeData = snapshot.data;

            if (pokeData == null) {
              return const Center(child: Text('No data available'));
            }

            return Column(
              children: [
                // Display the Pokémon image using Hero animation
                Hero(
                  tag: pokemonName,
                  child: imageViewer(pokeData),
                ),
                const SizedBox(height: 20),
                // Display base experience
                Text('Base Experience: ${pokeData.details['baseExperience']}'),
                const SizedBox(height: 10),
                // Display abilities
                if (pokeData.details['abilities'] != null) ...[
                  const Text('Abilities:'),
                  ...pokeData.details['abilities']!.map((ability) {
                    return Text(
                      '- ${ability['ability']['name']} ${ability['is_hidden'] ? "(Hidden)" : ""}',
                    );
                  }).toList(),
                ],
              ],
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget imageViewer(PokeData pokeData) {
    String imgUrl1 = pokeData.details['sprites']['front_default'];
    String imgUrl2 = pokeData.details['sprites']['other']?['official-artwork']
        ?['front_default'];

    return FutureBuilder(
      future: Future.delayed(Duration(seconds: 1), () async {
        // Simulate a delay to show img1 first
        try {
          final image = Image.network(imgUrl2);
          final completer = Completer<void>();
          image.image.resolve(ImageConfiguration()).addListener(
                ImageStreamListener(
                  (ImageInfo image, bool synchronousCall) {
                    completer.complete();
                  },
                  onError: (error, stackTrace) {
                    completer.complete();
                  },
                ),
              );
          return completer.future;
        } catch (e) {
          return;
        }
      }),
      builder: (context, snapshot) {
        return FadeInImage(
          placeholder: NetworkImage(imgUrl1),
          image: NetworkImage(imgUrl2),
          fit: BoxFit.contain,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 300),
          imageErrorBuilder: (context, error, stackTrace) {
            // In case img2 fails to load, just show img1
            return Image.network(imgUrl1, fit: BoxFit.contain);
          },
        );
      },
    );
  }
}
