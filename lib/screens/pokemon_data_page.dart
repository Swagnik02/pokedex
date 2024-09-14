import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pokedex/extensions/string_casing_extension.dart';
import 'package:pokedex/extensions/type_colours.dart';
import 'package:pokedex/models/poke_model.dart';
import 'package:pokedex/providers/poke_provider.dart';
import 'package:pokedex/widgets/themes.dart';
import 'package:provider/provider.dart';

class PokemonDataPage extends StatelessWidget {
  final String pokemonName;
  final Color domColor;

  const PokemonDataPage({
    super.key,
    required this.pokemonName,
    required this.domColor,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData dynamicTheme = ThemeData(
      primaryColor: domColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: domColor,
      ),
      scaffoldBackgroundColor: domColor.withOpacity(0.8),
      tabBarTheme: TabBarTheme(
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: domColor, width: 4),
        ),
        labelColor: domColor,
        unselectedLabelColor: Colors.grey,
      ),
    );

    return Theme(
      data: dynamicTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white60,
            ),
          ),
        ),
        body: FutureBuilder<PokeData?>(
          future: Future.delayed(Duration.zero, () {
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

              return DefaultTabController(
                length: 4,
                child: Stack(
                  children: [
                    _header(context, pokeData),
                    _stats(pokeData),
                    _image(pokeData),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Row _image(PokeData pokeData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Hero(
          tag: pokemonName,
          child: SizedBox(
            height: 300,
            child: imageViewer(pokeData),
          ),
        ),
      ],
    );
  }

  Column _stats(PokeData pokeData) {
    return Column(
      children: [
        const SizedBox(height: 230),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'About'),
                    Tab(text: 'Stats'),
                    Tab(text: 'Evolution'),
                    Tab(text: 'Moves'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAboutTab(pokeData),
                      _buildBaseStatsTab(pokeData),
                      _buildEvolutionTab(pokeData),
                      _buildMovesTab(pokeData),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, PokeData pokeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pokeData.name.toCapitalized,
                style: TextThemeStyle(context).themeHeadlineLarge,
              ),
              Wrap(
                children: pokeData.details['types'].map<Widget>((type) {
                  return Card(
                    elevation: 3,
                    color: typeColors[type['type']['name'].toLowerCase()] ??
                        Colors.grey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        type['type']['name'].toString().toCapitalized,
                        style: TextThemeStyle(context).themeOfChips,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                pokeData.details['id'].toString().toPokedexId,
                style: TextThemeStyle(context).themeHeadlineLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget imageViewer(PokeData pokeData) {
    String imgUrl1 = pokeData.details['sprites']['front_default'];
    String imgUrl2 = pokeData.details['sprites']['other']?['official-artwork']
        ?['front_default'];

    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1), () async {
        try {
          final image = Image.network(imgUrl2);
          final completer = Completer<void>();
          image.image.resolve(const ImageConfiguration()).addListener(
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
            return Image.network(imgUrl1, fit: BoxFit.contain);
          },
        );
      },
    );
  }

  Widget _buildAboutTab(PokeData pokeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Species: ${pokeData.details['species']['name']}'),
          const SizedBox(height: 10),
          Text('Height: ${pokeData.details['height']} dm'),
          const SizedBox(height: 10),
          Text('Weight: ${pokeData.details['weight']} hg'),
          const SizedBox(height: 10),
          if (pokeData.details['abilities'] != null) ...[
            const Text('Abilities:'),
            ...pokeData.details['abilities']!.map<Widget>((ability) {
              return Text(
                '- ${ability['ability']['name']} ${ability['is_hidden'] ? "(Hidden)" : ""}',
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildBaseStatsTab(PokeData pokeData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: pokeData.details['stats']!.map<Widget>((stat) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat['stat']['name']),
              Text(stat['base_stat'].toString()),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEvolutionTab(PokeData pokeData) {
    // Placeholder content
    return const Center(child: Text('Evolution data is not available.'));
  }

  Widget _buildMovesTab(PokeData pokeData) {
    // Placeholder content
    return const Center(child: Text('Moves data is not available.'));
  }
}
