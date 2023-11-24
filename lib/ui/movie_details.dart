import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;

      setState(() {
        isLike = false; // Set to false if user is not authenticated
      });
      // Check if the movie is liked by the user
      isMovieLiked(userId, widget.results.title!);
    }
  }

  Future<void> isMovieLiked(String userId, String movieTitle) async {
    final favoriteListCollection =
        FirebaseFirestore.instance.collection('favoriteList');

    final querySnapshot = await favoriteListCollection
        .where('userID', isEqualTo: userId)
        .where('movieTitle', isEqualTo: movieTitle)
        .get();

    setState(() {
      isLike = querySnapshot.docs.isNotEmpty;
    });
  }

  Future<void> _toggleLike(String userId, int movieID, String movieTitle,
      String description, String posterPath) async {
    final favoriteListCollection =
        FirebaseFirestore.instance.collection('favoriteList');

    if (isLike) {
      final querySnapshot = await favoriteListCollection
          .where('userID', isEqualTo: userId)
          .where('movieTitle', isEqualTo: movieTitle)
          .get();

      for (final doc in querySnapshot.docs) {
        await favoriteListCollection.doc(doc.id).delete();
        print('Movie deleted successfully');

        setState(() {
          isLike = false;
        });
        const snackBar = SnackBar(
          content: Text('Removed from lists'),
          backgroundColor: CupertinoColors.systemRed,
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      await favoriteListCollection.add({
        'userID': userId,
        'movieID': movieID,
        'movieTitle': movieTitle,
        'description': description,
        'posterPath': posterPath,
      });
      setState(() {
        isLike = true;
      });
      const snackBar = SnackBar(
        content: Text('Added to Favorites'),
        backgroundColor: Colors.blue,
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: isLike == null,
      child: Scaffold(
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
                    'https://image.tmdb.org/t/p/w500/${widget.results.backdropPath!}'),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(isLike ? Icons.favorite : Icons.favorite_border),
                    color: Colors.red,
                    onPressed: () {
                      debugPrint('>>>Clicked');
                      _toggleLike(
                          user!.uid,
                          widget.results.id!,
                          widget.results.title!,
                          widget.results.overview!,
                          widget.results.backdropPath!);
                    },
                  ),
                ],
              )
              // SizedBox(
              //   child: IconButton(
              //     onPressed: () {},
              //     icon: const Icon(
              //       Icons.favorite_border,
              //         color: Colors.red,
              //     ),
              //   ),
              // ),
              ,
              Row(
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
                style: GoogleFonts.lato(
                    fontSize: 18, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
