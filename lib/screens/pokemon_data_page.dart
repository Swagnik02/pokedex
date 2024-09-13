import 'package:flutter/material.dart';
import 'package:pokedex/extensions/string_casing_extension.dart';
import 'package:pokedex/providers/poke_provider.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PokemonDataPage extends StatelessWidget {
  final String pokemonName;

  const PokemonDataPage({
    super.key,
    required this.pokemonName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pokemonName.toString().toCapitalized)),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: Provider.of<PokemonProvider>(context, listen: false)
            .fetchPokemonData(
                'https://pokeapi.co/api/v2/pokemon/$pokemonName'), // Pass the URL
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data;

            if (data == null || !data.containsKey('sprites')) {
              return const Center(child: Text('No data available'));
            }

            var sprites = data['sprites'];

            // Extract sprite URLs into a list, handling potential nulls
            List<String> spriteUrls = [
              sprites['front_default'] as String?,
              sprites['back_default'] as String?,
              sprites['other']?['official-artwork']?['front_default']
                  as String?,
            ].whereType<String>().toList(); // Remove nulls safely

            return Column(
              children: [
                // Display carousel of sprite images
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300.0,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: spriteUrls.map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          url,
                          fit: BoxFit.contain,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (data.containsKey('base_experience'))
                  Text('Base Experience: ${data['base_experience']}'),
                const SizedBox(height: 10),
                if (data.containsKey('abilities')) ...[
                  const Text('Abilities:'),
                  ...data['abilities'].map<Widget>((ability) {
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
}
