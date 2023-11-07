import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:movie_db/services/api_service.dart';

import 'models/movie_model.dart';

class Movies extends StatefulWidget {
  const Movies({super.key});

  @override
  State<Movies> createState() {
    return _MoviesState();
  }
}

class _MoviesState extends State<Movies> {

  final _apiServices = ApiService();
  MovieModel? model;
  String? movieName;
  int? budget;
  String? tagLine;

  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  // getData() async {
  //   _apiServices.getAllMovies(token).then((value) {
  //     debugPrint('MovieValue>>>>>>>$value');
  //     model = value;
  //     movieName = model?.title;
  //     tagLine= model?.tagline;
  //     budget = model?.budget;
  //
  //     debugPrint('MovieName>>>>>>>$tagLine');
  //   });
  // }

  @override
  void initState() {
    // getData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [Text(tagLine!),
            Text(budget.toString())],
        ),

      ),
    );
  }
}



























// import 'dart:ffi';
//
// import 'package:flutter/material.dart';
// import 'package:movie_db/services/api_service.dart';
// import 'dart:convert';
//
// import 'models/movie_model.dart';
// import 'package:http/http.dart' as http;
//
//
// class Movies extends StatefulWidget {
//   const Movies({super.key});
//
//   @override
//   State<Movies> createState() {
//     return _MoviesState();
//   }
// }
//
// class _MoviesState extends State<Movies> {
//
//   Future<List<MovieModel>> moviesFuture = getAllMovies();
//
//   static Future<List<MovieModel>> getAllMovies() async {
//     Map<String, String> headers = {
//       "Authorization": "Bearer ",
//     };
//     final response = await http.get(Uri.parse(
//         'https://api.themoviedb.org/3/movie/11?api_key=14bf3761ec6892a715b5655eaf54fecc'),
//         headers: headers);
//     final List resp = jsonDecode(response.body);
//
//     return resp.map((e) => MovieModel.fromJson(e)).toList();
//   }
//
//
//   String token =
//       'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           children: [Text(tagLine!),
//             Text(budget.toString())],
//         ),
//
//       ),
//     );
//   }
// }
