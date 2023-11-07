import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:movie_db/models/movie_model.dart';

class ApiService {


  static Future<List<MovieModel>> getAllMovies(String token) async {
    Map<String, String> headers = {
      "Authorization": "Bearer $token",
    };
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/11?api_key=14bf3761ec6892a715b5655eaf54fecc'),
        headers: headers);
    final List resp = jsonDecode(response.body);

    return resp.map((e) => MovieModel.fromJson(e)).toList();
  }


}
