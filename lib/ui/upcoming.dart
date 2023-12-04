import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_db/ui/movie_details.dart';
import 'package:movie_db/services/api_service.dart';
import 'package:movie_db/models/toprated_model.dart';
import 'package:transparent_image/transparent_image.dart';

class Upcoming extends StatefulWidget {
  const Upcoming({super.key});

  @override
  State<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends State<Upcoming> {
  final _apiServices = ApiService();

  final baseUrl =
      'https://api.themoviedb.org/3/movie/upcoming?api_key=14bf3761ec6892a715b5655eaf54fecc';
  final apiKey = '14bf3761ec6892a715b5655eaf54fecc';
  String token =
      'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxNGJmMzc2MWVjNjg5MmE3MTViNTY1NWVhZjU0ZmVjYyIsInN1YiI6IjY1NDBlNWM2ZWVjNWI1MDBhZWIyODg4MCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.M468gNmCenEX-lpFcQ_ednEZ9UaaQAHGJp-Z_ZrfI8I';

  Future<TopRated>? getUpcoming() {
    _apiServices.getUpcoming(token);
  }

  @override
  void initState() {
    // TODO: implement initState
    getUpcoming();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TopRated?>(
      future: _apiServices.getUpcoming(token),
      builder: (BuildContext context, AsyncSnapshot<TopRated?> snapshot) {
        Widget child = SizedBox();
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          child = Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          debugPrint('snapshotData${snapshot.data}');

          if (snapshot.hasData) {
            final data = snapshot.data?.results;
            child = ListView.builder(
              itemCount: data?.length,
              itemBuilder: (BuildContext context, int index) {
                var description = data?[index].overview;

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
                          ),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image:
                                'https://image.tmdb.org/t/p/w500/${data![index].posterPath!}',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      )
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
