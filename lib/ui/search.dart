import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/toprated_model.dart';
import 'movie_details.dart';
import 'package:movie_db/services/movieApi.dart';
import 'package:http/http.dart' as http;


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final MovieApi _movieApi = MovieApi();
  final TextEditingController _searchController = TextEditingController();
  List<Results> _searchResults = [];
  Timer? _debounceTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchController.addListener(_performSearch);
  }

  void _performSearch() async {
    final String searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      try {
        final TopRated movies = await _movieApi.getMovies(searchQuery);
         List<Results>? searchedMovie = movies.results;
        setState(() {
          _searchResults = searchedMovie!;
        });
      }
      catch (e) {
        print('Error fetching movies: $e');
      }
    } else {
      // setState(() {
      //   _searchResults.clear();
      // });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: InkWell( onTap:(){
        //   _performSearch();
        //
        // },child:Icon(Icons.search)),
        title: TextField(
          controller: _searchController,
          onChanged: (value){
              _debounceTimer?.cancel(); // Cancel previous timer if it exists.

              _debounceTimer = Timer(Duration(milliseconds: 300), () {
                _performSearch();
                },);},
          decoration: InputDecoration(
            hintText: 'Search movies',
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    borderSide: BorderSide(
    color: Colors.blue,
    ),

    ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // _performSearch();

            }
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final Results movie = _searchResults[index];
          var description = movie.overview!;
          return ListTile(
            onTap: () async {
              final movieId = movie.id.toString();
              final Results? movieDetails =
              await getMovieDetails(movieId!);
              debugPrint('>>>>>WE ARE HERE!!!!!!!!!!!!!!!!');
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => MovieDetails(
                    results: movieDetails!,
                  ),
                ),
              );
            },
            title: Text(movie.title!),
            subtitle: Text(description.length > 100 ? '${description.substring(0,100)}...' : description
          ),
            leading: Image.network(
              'https://image.tmdb.org/t/p/w500/${movie.posterPath}',
              width: 50,
              height: 75,
            ),
            contentPadding: EdgeInsets.fromLTRB(7, 10, 0, 10),
          );
        },
      ),
    );
  }
  }

