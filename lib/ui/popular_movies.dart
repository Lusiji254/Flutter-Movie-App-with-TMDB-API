import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/movie_details.dart';
import 'package:movie_db/services/api_service.dart';
import 'top_rated.dart';

import '../models/movie_model.dart';

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
        title: const Center(child: Text('Popular Movies')),
      ),
      // implement FutureBuilder
      body: FutureBuilder<TopRated?>(
        future: _apiServices.getPopularMovies(token),
        builder: (BuildContext context, AsyncSnapshot<TopRated?> snapshot) {
          Widget child = SizedBox();
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.active) {
            child = Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            debugPrint('snapshotData${snapshot.data}');

            if (snapshot.hasData) {
              final data = snapshot.data?.results;
              child = GridView.builder(
                itemCount: data?.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 1),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(onTap: (){

                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) =>  MovieDetails(results: data[index], ),),);
                        },
                          child: Card(

                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                  'https://image.tmdb.org/t/p/w500/' +
                                      data![index].backdropPath!),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(data![index].title!, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.normal),)
                      ],
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