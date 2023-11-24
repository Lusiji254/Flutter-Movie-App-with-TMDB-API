import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movie_db/models/toprated_model.dart';


class MovieApi {
  static const String apiKey = '14bf3761ec6892a715b5655eaf54fecc';
  static const String baseUrl = 'https://api.themoviedb.org/3/';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';


  Future<TopRated> getMovies(String searchQuery) async {
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Api-Key": apiKey,
    };

    final response = await http.get(
      Uri.parse('$baseUrl/search/movie?query=$searchQuery&api_key=$apiKey&'),headers: headers
    );
    debugPrint('SearchQuery>>${response.body}');


    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      // final List<Movie> movies = List.from(data['results'])
      //     .map((movieData) => Movie.fromJson(movieData))
      //     .toList();
      // debugPrint('Search!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!$movies');
      return TopRated.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.statusCode);
    }
  }
}


class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;


  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
  });


  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path']
    );
  }
}
