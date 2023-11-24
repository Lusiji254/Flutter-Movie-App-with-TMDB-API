import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/movie_details.dart';
import 'package:movie_db/services/api_service.dart';
import 'package:movie_db/ui/search.dart';

class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() {
    return _MoviesState();
  }
}

class _MoviesState extends State<Movies> {
  final _apiServices = ApiService();

  final baseUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=14bf3761ec6892a715b5655eaf54fecc';
  final apiKey = '14bf3761ec6892a715b5655eaf54fecc';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  Future<TopRated?> getAllMovies() async {
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Api-Key": apiKey,
    };
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    debugPrint('Response>>>${response.toString()}');
    var resp = jsonDecode(response.body);
    debugPrint('Response>>>${resp.toString()}');

    if (response.statusCode == 200) {
      return TopRated.fromJson(jsonDecode(response.body));
    } else {
      response.statusCode;
    }
  }

  List<Results>? results = [];
  TopRated? moviesModel;

  Future<TopRated>? getPopularMovies() {
    _apiServices.getPopularMovies(token);
  }

  @override
  void initState() {
    // getAllMovies();
    // getPopularMovies();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // flexibleSpace: Align(
        // alignment: Alignment.center,
        //   child:Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Center(
        //       child: Text(
        //         'Centered Title',
        //         style: TextStyle(
        //           fontSize: 18.0,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),),
        // title: Align(
        //   alignment: Alignment.center,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Text(
        //         'Popular Movie',
        //         style: TextStyle(
        //           fontSize: 18.0,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        title: Center(child: Text('Popular Movies'),),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Search(),
              ),
            );
          },
          icon: Icon(Icons.search),
        ),
      ),
      body: FutureBuilder<TopRated?>(
        future: _apiServices.getPopularMovies(token),
        builder: (BuildContext context, AsyncSnapshot<TopRated?> snapshot) {
          Widget child = const SizedBox();
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            child = const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            debugPrint('snapshotData${snapshot.data}');

            if (snapshot.hasData) {
              final data = snapshot.data?.results;
              child = GridView.builder(
                padding: EdgeInsets.all(5),
                itemCount: data?.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: (120.0 / 185.0),
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (_) => MovieDetails(
                            results: data[index],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://image.tmdb.org/t/p/w500/${data![index].posterPath!}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          return child;
        },
      ),
    );
  }
}
