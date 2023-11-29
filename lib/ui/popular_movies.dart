import 'package:flutter/material.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/movie_details.dart';
import 'package:movie_db/services/api_service.dart';


class Movies extends StatefulWidget {
  final int selectedGenreId;

  final String keyword;

  const Movies({Key? key, required this.selectedGenreId, required this.keyword})
      : super(key: key);

  @override
  State<Movies> createState() {
    return _MoviesState(selectedGenreId: selectedGenreId, keyword: keyword);
  }
}

class _MoviesState extends State<Movies> {
  final _apiServices = ApiService();

  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  List<Results>? results = [];
  TopRated? moviesModel;
  final int selectedGenreId;

  _MoviesState({required this.selectedGenreId, required String keyword});

  List<Results>? filterMoviesByGenre(List<Results>? movies, int genreId) {
    return movies
        ?.where((movie) => movie.genreIds?.contains(genreId) ?? false)
        .toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TopRated?>(
      future: _apiServices.getCategory(token, widget.keyword),
      builder: (BuildContext context, AsyncSnapshot<TopRated?> snapshot) {
        Widget child = SizedBox();
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          child = Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          debugPrint('snapshotData${snapshot.data}');

          if (snapshot.hasData) {
            final dataResults = snapshot.data?.results;
            debugPrint('>>>Popular:   ${dataResults}');
            debugPrint(selectedGenreId.toString());
            final data = filterMoviesByGenre(dataResults, selectedGenreId);
            debugPrint('>>>Popular:   ${data}');
            child = ListView.builder(
              itemCount: data?.length,
              itemBuilder: (BuildContext context, int index) {
                var description = data?[index].overview;

                debugPrint(data?[index].title);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      GestureDetector(
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
                          width: 150.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            image: DecorationImage(
                              image: NetworkImage(
                                  'https://image.tmdb.org/t/p/w500/${data![index].posterPath!}'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data[index].title!,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              data[index].releaseDate!,
                              style: TextStyle(color: Colors.grey),
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
    );
  }
}
