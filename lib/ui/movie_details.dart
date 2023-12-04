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

  Future<void> _toggleLike(
    String userId,
    int movieID,
    String movieTitle,
    String description,
    String posterPath,
  ) async {
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
        backgroundColor: Color.fromARGB(255, 33, 10, 18),
        body: CustomScrollView(
          // sliver app bar
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: MediaQuery.of(context).size.height / 2.1,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://image.tmdb.org/t/p/w500/${widget.results.posterPath!}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((ctx, _) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          widget.results.title!,
                          style: GoogleFonts.poppins(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month, color: Colors.white),
                              SizedBox(width: 20),
                              Text(
                                widget.results.releaseDate!,
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star, color: Colors.white),
                              SizedBox(width: 20),
                              Text(
                                widget.results.voteAverage!.toString(),
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(isLike
                                ? Icons.favorite
                                : Icons.favorite_border),
                            color: Colors.red,
                            onPressed: () {
                              debugPrint('>>>Clicked');
                              _toggleLike(
                                user!.uid,
                                widget.results.id!,
                                widget.results.title!,
                                widget.results.overview!,
                                widget.results.posterPath!,
                              );
                            },
                          ),
                        ],
                      ),
                      Text(
                        'Description',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        widget.results.overview!,
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                );
              }, childCount: 1),
            ),
          ],
        ),
      ),
    );
  }
}
