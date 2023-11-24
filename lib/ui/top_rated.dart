import 'package:flutter/material.dart';
import 'package:movie_db/ui/movie_details.dart';
import 'package:movie_db/services/api_service.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:movie_db/ui/search.dart';

class TopRatedMovies extends StatefulWidget {
  const TopRatedMovies({super.key});

  @override
  State<TopRatedMovies> createState() {
    return _TopRatedMoviesState();
  }
}

class _TopRatedMoviesState extends State<TopRatedMovies> {
  final _apiServices = ApiService();

  final baseUrl =
      'https://api.themoviedb.org/3/movie/popular?api_key=14bf3761ec6892a715b5655eaf54fecc';
  final apiKey = '14bf3761ec6892a715b5655eaf54fecc';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  Future<TopRated>? getTopRated() {
    _apiServices.getTopRated(token);
  }

  @override
  void initState() {
    // TODO: implement initState
    getTopRated();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Top Rated Movies'),),

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
        future: _apiServices.getTopRated(token),
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
