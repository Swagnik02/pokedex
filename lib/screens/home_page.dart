import 'package:flutter/material.dart';
import 'package:pokedex/providers/poke_provider.dart';
import 'package:pokedex/widgets/custom_pokemon_tile.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int offset = 0;
  int offsetChangeValue = 6;
  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPokemonList();
    });
  }

  // Fetch Pokémon list from the provider
  void _fetchPokemonList() {
    Provider.of<PokemonProvider>(context, listen: false).fetchPokeList(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poké Tab'),
      ),
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (provider.errorMessage != null) {
            return Center(
              child: Text('Error: ${provider.errorMessage}'),
            );
          } else if (provider.pokeList.isNotEmpty) {
            // Pokémon list is available
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemCount: provider.pokeList.length,
                    itemBuilder: (context, index) {
                      final pokemon = provider.pokeList[index];
                      return customPokemonTile(pokemon, context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: offset != 0
                        ? MainAxisAlignment.spaceAround
                        : MainAxisAlignment.end,
                    children: [
                      if (offset != 0)
                        OutlinedButton(
                          onPressed: () {
                            if (offset > 0) {
                              setState(() {
                                offset -= offsetChangeValue;
                                _fetchPokemonList();
                              });
                            }
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.arrow_back_ios),
                              Text('Previous Page'),
                            ],
                          ),
                        ),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            offset += offsetChangeValue;
                            _fetchPokemonList();
                          });
                        },
                        child: const Row(
                          children: [
                            Text('Next Page'),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
