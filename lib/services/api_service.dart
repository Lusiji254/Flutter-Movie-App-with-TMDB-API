import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:movie_db/models/movies_model.dart';
import 'package:movie_db/models/error_model.dart';
import 'package:movie_db/models/toprated_model.dart';

import '../models/movie_model.dart';

class ApiService {
  final baseUrl = 'https://api.themoviedb.org/3/movie/';
  final apiKey = '14bf3761ec6892a715b5655eaf54fecc';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  getMovie(String token) async {
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
      "Api-Key": apiKey,
    };
    final response = await http.get(Uri.parse(baseUrl), headers: headers);
    debugPrint('Response>>>${response.toString()}');
    var resp = jsonDecode(response.body);
    debugPrint('Response>>>${resp.toString()}');

    if (response.statusCode == 200) {
      return MovieModel.fromJson(jsonDecode(response.body));
    } else {
      response.statusCode;
    }
  }

  Future<TopRated?> getPopularMovies(String token) async {
    String keyword = 'popular?';
    final url = baseUrl + keyword + 'api_key=' + apiKey;

    final response = await http.get(Uri.parse(url));
    debugPrint('>>>>response$response');
    debugPrint('>>>>response${response.statusCode}');

    if (response.statusCode == 200) {

      return TopRated.fromJson(jsonDecode(response.body));

    } else {

    }
  }

  Future<TopRated?>getTopRated(String token)async{

    String keyword = 'top_rated?';
    final url = baseUrl + keyword + 'api_key=' + apiKey;

    final response = await http.get(Uri.parse(url));
    debugPrint('>>>>response$response');
    debugPrint('>>>>response${response.statusCode}');
    debugPrint('Response>>>${response.toString()}');

    if (response.statusCode == 200) {

      return TopRated.fromJson(jsonDecode(response.body));

    } else {

    }
  }
}
