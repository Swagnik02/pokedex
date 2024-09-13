import 'package:flutter/material.dart';
import 'package:pokedex/providers/poke_provider.dart';
import 'package:pokedex/screens/pokemon_data_page.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/extensions/string_casing_extension.dart'; // Ensure this import is correct

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PokemonProvider>(context, listen: false).fetchPokeList();
    });
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
            return const Center(child: CircularProgressIndicator());
          } else if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          } else if (provider.pokeModel != null) {
            var results = provider.pokeModel!.data['results'];
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final pokemon = results[index];
                final pokemonName = pokemon['name']
                    .toString()
                    .toCapitalized; // Use the extension here
                return ListTile(
                  title: Text(pokemonName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PokemonDataPage(pokemonName: pokemon['name']),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
