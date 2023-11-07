import 'dart:math';

import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/movie_hive_model.dart';

class MovieDetails extends StatefulWidget {
  MovieDetails({super.key, required this.results});

  Results results;

  @override
  State<MovieDetails> createState() {
    return _MovieDetailsState();
  }
}

class _MovieDetailsState extends State<MovieDetails> {
  late bool isLike;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLike = Hive.box<MovieHiveModel>('movies').get(widget.results.id) != null;

  }

  void _toggleLike() {
    setState(() {
      final box = Hive.box<MovieHiveModel>('movies');

      if (isLike) {
        box.delete(widget.results.id);
        isLike = false;
        const snackBar = SnackBar(
          content: Text('Removed from Favorites'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final movieHiveModel = MovieHiveModel(
          id: widget.results.id!,
          title: widget.results.title!,
          overview: widget.results.overview!,
          posterPath: widget.results.posterPath!,
          adult: widget.results.adult!,
          backdropPath: widget.results.backdropPath!,
          genreIds: widget.results.genreIds!,
          originalLanguage: widget.results.originalLanguage!,
          originalTitle: widget.results.originalTitle!,
          popularity: widget.results.popularity!,
          releaseDate: widget.results.releaseDate!,
          video: widget.results.video!,
          voteAverage: widget.results.voteAverage!,
          voteCount: widget.results.voteCount!,

        );
        box.put(widget.results.id, movieHiveModel);

        isLike = true;

        const snackBar = SnackBar(
          content: Text('Added to Favorites'),
          backgroundColor: Colors.blue,
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.results.title!),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                  'https://image.tmdb.org/t/p/w500/${widget.results
                      .backdropPath!}'),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(

                  icon: Icon(isLike ? Icons.favorite : Icons.favorite_border),
                  color: Colors.red,
                  onPressed:()
                  {
                  debugPrint('>>>Clicked');
                  _toggleLike();
                  },),
              ],)
            // SizedBox(
            //   child: IconButton(
            //     onPressed: () {},
            //     icon: const Icon(
            //       Icons.favorite_border,
            //         color: Colors.red,
            //     ),
            //   ),
            // ),
            , Row(
              children: [
                Text(
                  'Release Date : ',
                  style: GoogleFonts.lato(
                      fontSize: 19, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.results.releaseDate!,
                  style: GoogleFonts.lato(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            Text(
              'Description:',
              style:
              GoogleFonts.lato(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.results.overview!,
              style:
              GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
