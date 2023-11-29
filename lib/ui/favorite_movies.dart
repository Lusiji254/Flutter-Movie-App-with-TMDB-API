import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/search.dart';
import 'package:transparent_image/transparent_image.dart';

import 'movie_details.dart';

class FavoriteMovies extends StatefulWidget {
  const FavoriteMovies({super.key});

  @override
  State<FavoriteMovies> createState() => _FavoriteMoviesState();
}

class _FavoriteMoviesState extends State<FavoriteMovies> {
  final User? user = FirebaseAuth.instance.currentUser;
  late Stream<QuerySnapshot> _likedMoviesStream;

  // List<String> documentIds = []; // Store document IDs here

  Stream<QuerySnapshot> getUserLikedMoviesStream(String userId) {
    final favoriteListCollection =
        FirebaseFirestore.instance.collection('favoriteList');
    return favoriteListCollection
        .where('userID', isEqualTo: userId)
        .snapshots();
  }

  Future<void> deleteFavoriteMovie(String userId, String movieTitle) async {
    final favoriteListCollection =
        FirebaseFirestore.instance.collection('favoriteList');

    // Query the documents with the matching userID and movieTitle
    final querySnapshot = await favoriteListCollection
        .where('userID', isEqualTo: userId)
        .where('movieTitle', isEqualTo: movieTitle)
        .get();

    for (final doc in querySnapshot.docs) {
      try {
        await favoriteListCollection.doc(doc.id).delete();
        print('Movie deleted successfully');

        const snackBar = SnackBar(
          content: Text('Removed from lists'),
          backgroundColor: CupertinoColors.systemRed,
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        print('Error deleting movie: $e');
      }
    }
  }

  Future<Results?> getMovieDetails(String movieId) async {
    final apiKey = '14bf3761ec6892a715b5655eaf54fecc';
    final response = await http.get(
      Uri.parse('https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey'),
    );
    debugPrint('Response>>>${response.toString()}');
    // final data = json.decode(response.body);

    if (response.statusCode == 200) {
      debugPrint('SUCCESSSSSSSS');
      var results = Results.fromJson(jsonDecode(response.body));
      debugPrint('Results>>>${results.toString()}');
      return results;
    } else {
      response.statusCode;
    }
  }

  @override
  void initState() {
    super.initState();

    if (user != null) {
      final userId = user?.uid;
      _likedMoviesStream = getUserLikedMoviesStream(userId!);
      // Optionally, you can also listen to changes in the Firestore data and update the stream.
      _likedMoviesStream.listen((querySnapshot) {
        // Update the stream with the latest data from Firestore.
        setState(() {
          _likedMoviesStream = Stream.value(querySnapshot);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 33, 10, 18),
      body: user == null
          ? const Center(
              child: Text('Please log in to view your liked movies.'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: _likedMoviesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('You have not liked any movies yet.'));
                }

                final likedMovies = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: likedMovies.length,
                  itemBuilder: (context, index) {
                    final movieData =
                        likedMovies[index].data() as Map<String, dynamic>?;
                    var description = movieData?['description'];

                    debugPrint('>>>>>>>>DATA${movieData?['movieTitle']}');
                    debugPrint('>>>>>>>>DATA${movieData?['posterPath']}');

                    return Dismissible(
                      key: ValueKey(movieData?['movieTitle']),
                      onDismissed: (direction) async {
                        await deleteFavoriteMovie(
                            user?.uid as String, movieData?['movieTitle']);

                        // Update the stream to reflect the removed item.
                        setState(() {
                          _likedMoviesStream =
                              getUserLikedMoviesStream(user?.uid as String);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final movieId =
                                    movieData?['movieID'].toString();
                                final Results? movieDetails =
                                    await getMovieDetails(movieId!);
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetails(
                                      results: movieDetails!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100.0,
                                height: 150.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          'https://image.tmdb.org/t/p/w500/${movieData?['posterPath']}'),
                                    )),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movieData?['movieTitle'] ??
                                          'Unknown Title',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                        description!.length > 100
                                            ? '${description!.substring(0, 100)}...'
                                            : description!,
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            )
                            // ListTile(
                            //   onTap: () async {
                            //     final movieId = movieData?['movieID'].toString();
                            //     final Results? movieDetails =
                            //         await getMovieDetails(movieId!);
                            //     debugPrint('>>>>>WE ARE HERE!!!!!!!!!!!!!!!!');
                            //     Navigator.of(context, rootNavigator: true).push(
                            //       MaterialPageRoute(
                            //         builder: (context) => MovieDetails(
                            //           results: movieDetails!,
                            //         ),
                            //       ),
                            //     );
                            //   },
                            //   leading: Container(
                            //     decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(
                            //           10.0), // Adjust the corner radius as needed
                            //     ),
                            //     child: ClipRRect(
                            //       borderRadius: BorderRadius.circular(8.0),
                            //       child: Image.network(
                            //         'https://image.tmdb.org/t/p/w500/${movieData?['posterPath']}',
                            //         width: 200.0, // Adjust the width of the poster as needed
                            //         height: 200.0,
                            //         fit: BoxFit.cover,
                            //       ),
                            //     ),
                            //
                            //   ),
                            //   title: Text(
                            //     movieData?['movieTitle'] ?? 'Unknown Title',
                            //   ),
                            //   contentPadding: EdgeInsets.fromLTRB(7, 10, 0, 10),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
