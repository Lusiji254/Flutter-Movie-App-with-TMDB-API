import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_db/ui/popular_movies.dart';
import 'package:movie_db/ui/top_rated.dart';
import 'package:movie_db/ui/favorite_movies.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DefaultTabController(
        length: 3, // Number of tabs (Popular Movies and Top Rated Movies)
        child: Scaffold(
          body: TabBarView(
            children: [Movies(), TopRatedMovies(), FavoriteMovies()],
          ),
          bottomNavigationBar: TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                ),
              ),
              Tab(
                  icon: Icon(
                Icons.star,
                color: Colors.yellowAccent,
              )),
              Tab(
                  icon: Icon(
                Icons.favorite,
                color: Colors.red,
              )),
            ],
            labelColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}
