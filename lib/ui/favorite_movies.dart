import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/movie_hive_model.dart';

class FavoriteMovies extends StatefulWidget {
  const FavoriteMovies({super.key});

  @override
  State<FavoriteMovies> createState() => _FavoriteMoviesState();
}

class _FavoriteMoviesState extends State<FavoriteMovies> {
  List<MovieHiveModel> likedMovies = [];
  final box = Hive.box<MovieHiveModel>('movies');


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    likedMovies = box.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Movies'),
      ),
      body: ListView.builder(
        itemCount: likedMovies.length,
        itemBuilder: (context, index) {
          final movie = likedMovies[index];

          return Dismissible(
            key: ValueKey(movie),
            onDismissed: (direction) async {
              await box.delete(movie.id);

              const snackBar = SnackBar(
                content: Text('Removed from lists'),
                backgroundColor: CupertinoColors.systemRed,
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(snackBar);

            },
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                    'https://image.tmdb.org/t/p/w500/${movie.backdropPath!}'),
              ),
              title: Text(movie.title),
              subtitle: Text(movie.overview.length > 100
                  ? '${movie.overview.substring(0, 100)}...'
                  : movie.overview),
              //contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            ),
          );
        },
      ),
    );
  }
}
