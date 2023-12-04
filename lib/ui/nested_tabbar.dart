import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_db/ui/popular_movies.dart';
import 'package:http/http.dart' as http;

class NestedTabBar extends StatefulWidget {
  const NestedTabBar(this.outerTab, this.onGenreSelected,
      {Key? key, required this.keyword})
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
  final apiKey =
      '14bf3761ec6892a715b5655eaf54fecc'; // Replace with your actual API key

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
            _tabController =
                TabController(length: genreList.length, vsync: this);
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
        ? Center(child: CircularProgressIndicator(color: Colors.deepOrange))
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
                        final genreId =
                            getGenreIdByName(genreList[index]['name']);
                        widget.onGenreSelected(genreId);
                      }
                    },
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: genreList.map((genre) {
                        final genreId = getGenreIdByName(genre['name']);
                        return Movies(
                          selectedGenreId: genreId,
                          keyword: widget.keyword,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
  }
}
