import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_db/ui/popular_movies.dart';
import 'package:movie_db/ui/search.dart';
import 'package:http/http.dart' as http;

import 'now_playing.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late TabController _tabController;
  int selectedGenreId = 0; // Add this variable to store the selected genre ID


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 33, 10, 18),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 12.0),
                      hintText: 'Search movies',
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Search(),
                        ),
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Now Playing',
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    color: Colors.white,
                    onPressed: () {
                      // Handle the tap on the three dots
                    },
                  ),
                ],
              ),
              Expanded(
                flex: 1,
                child: NowPlaying(),
              ),
              // SizedBox(height: 10),
              // Add some spacing between NowPlaying and 'Soon'
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soon',
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_horiz),
                          color: Colors.white,
                          onPressed: () {
                            // Handle the tap on the three dots
                          },
                        ),
                      ],
                    ),
                    Flexible(
                      child: DefaultTabController(
                        length: 3, // Number of tabs
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              tabs: [
                                buildTab('Popular'),
                                buildTab('Top Rated'),
                                buildTab('Upcoming'),
                              ],
                              labelColor: Colors.deepOrange,
                              unselectedLabelColor: Colors.white,
                              indicatorColor: Colors.transparent,
                              labelStyle: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              unselectedLabelStyle: TextStyle(fontSize: 16),
                            ),

                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  // Content for Tab 1
                                  NestedTabBar('Popular', (genreId) {
                                    setState(() {
                                      selectedGenreId = genreId;
                                      debugPrint('>>>>Genre ID: ${selectedGenreId}');
                                      // You can perform additional actions based on the selected genre if needed
                                    });

                                  }, keyword: 'popular?',),

                                  NestedTabBar('TopRated', (genreId) {
                                    setState(() {
                                      selectedGenreId = genreId;
                                      debugPrint('>>>>Genre ID: ${selectedGenreId}');
                                      // You can perform additional actions based on the selected genre if needed
                                    });

                                  }, keyword: 'top_rated?',),

                                  NestedTabBar('Upcoming', (genreId) {
                                    setState(() {
                                      selectedGenreId = genreId;
                                      debugPrint('>>>>Genre ID: ${selectedGenreId}');
                                      // You can perform additional actions based on the selected genre if needed
                                    });

                                  }, keyword: 'upcoming?',),
                                ],
                              ),
                            ),

                                                     ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTab(String text) {
    return Tab(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.deepOrange, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class NestedTabBar extends StatefulWidget {
  const NestedTabBar(this.outerTab, this.onGenreSelected, {Key? key, required this.keyword})
      : super(key: key);

  final String outerTab;
  final void Function(int) onGenreSelected;
  final String keyword;

  @override
  State<NestedTabBar> createState() => _NestedTabBarState();
}

class _NestedTabBarState extends State<NestedTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> genreList = [];
  bool isLoading = true;
  final apiKey = '14bf3761ec6892a715b5655eaf54fecc'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 1, vsync: this); // Initialize with a default length
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.themoviedb.org/3/genre/movie/list'
              '?api_key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        genreList = List<Map<String, dynamic>>.from(data['genres']);
        if (mounted) {
          setState(() {
            isLoading = false;
            _tabController = TabController(length: genreList.length, vsync: this);
          });
        }
      } else {
        throw Exception(response.statusCode.toString());
      }
    } catch (error) {
      print('Error: $error');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int getGenreIdByName(String genreName) {
    final genre = genreList.firstWhere(
          (g) => g['name'] == genreName,
      orElse: () => {'id': 0, 'name': ''},
    );
    return (genre['id'] ?? 0) as int;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator(color: Colors.deepOrange)
        : genreList.isEmpty
        ? Text('No genres available', style: TextStyle(color: Colors.white))
        : Column(
      children: <Widget>[
        TabBar(
          indicatorColor: Colors.deepOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          controller: _tabController,
          isScrollable: true,
          tabs: genreList.map((genre) {
            return Tab(
              text: genre['name'],
            );
          }).toList(),
          onTap: (index) {
            if (_tabController != null) {
              final genreId = getGenreIdByName(genreList[index]['name']);
              widget.onGenreSelected(genreId);
              //Movies.updateSelectedGenre(genreId); // Update selectedGenreId here

            }
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: genreList.map((genre) {
              final genreId = getGenreIdByName(genre['name']);
              return Movies(selectedGenreId: genreId, keyword: widget.keyword ,);
            }).toList(),
          ),
        ),
      ],
    );
  }
}
