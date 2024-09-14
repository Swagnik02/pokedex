import 'dart:math';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPokemonList();
    });
  }

  void _fetchPokemonList() {
    Provider.of<PokemonProvider>(context, listen: false).fetchPokeList(offset);
  }

  @override
  Widget build(BuildContext context) {
    final currentCount = (MediaQuery.of(context).size.width ~/ 200).toInt();
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
            return Stack(
              children: [
                Expanded(
                    child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: max(currentCount, 2),
                  ),
                  itemCount: provider.pokeList.length,
                  itemBuilder: (context, index) {
                    final pokeData = provider.pokeList[index];
                    return customPokemonTile(pokeData, context);
                  },
                )),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16),
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



  // Widget _imageViewer(PokeData? data) {
  //   bool isCarousel = false;
  //   var sprites = data!.details['sprites'];

  //   // Extract sprite URLs into a list, handling potential nulls
  //   List<String> spriteUrls = [
  //     sprites['front_default'] as String?,
  //     sprites['back_default'] as String?,
  //     sprites['other']?['official-artwork']?['front_default'] as String?,
  //   ].whereType<String>().toList();

  //   String singleSprite =
  //       sprites['other']?['official-artwork']?['front_default'];

  //   return isCarousel
  //       ? CarouselSlider(
  //           options: CarouselOptions(
  //             height: 300.0,
  //             autoPlay: true,
  //             enlargeCenterPage: true,
  //           ),
  //           items: spriteUrls.map((url) {
  //             return Builder(
  //               builder: (BuildContext context) {
  //                 return Image.network(
  //                   url,
  //                   fit: BoxFit.contain,
  //                 );
  //               },
  //             );
  //           }).toList(),
  //         )
  //       : Image.network(singleSprite);
  // }