import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_db/models/toprated_model.dart';
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
      debugPrint('SUCCESS');
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

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: (110.0 / 150.0),
                    crossAxisCount: 3,
                    // mainAxisSpacing: 10.0,
                  ),
                  itemCount: likedMovies.length,
                  itemBuilder: (context, index) {
                    final movieData =
                        likedMovies[index].data() as Map<String, dynamic>?;
                    var description = movieData?['description'];

                    return Dismissible(
                      key: ValueKey(movieData?['movieTitle']),
                      onDismissed: (direction) async {
                        await deleteFavoriteMovie(
                            user?.uid as String, movieData?['movieTitle']);
                        setState(() {
                          _likedMoviesStream =
                              getUserLikedMoviesStream(user?.uid as String);
                        });
                      },
                      background: Container(
                        color: Colors.red.withOpacity(0.5),
                        alignment: Alignment.centerRight,
                        //padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
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
                              child: Card(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: Image.network(
                                      'https://image.tmdb.org/t/p/w500/${movieData?['posterPath']}'),
                                ),
                              ),
                            ),
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
