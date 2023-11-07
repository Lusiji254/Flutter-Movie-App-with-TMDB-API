import 'package:hive/hive.dart';

part 'movie_hive_model.g.dart'; // This is required for Hive code generation

@HiveType(typeId: 0)
class MovieHiveModel {
  MovieHiveModel({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });
  @HiveField(0)
  bool adult;
  @HiveField(1)
  String backdropPath;
  @HiveField(2)
  List<int> genreIds;
  @HiveField(3)
  int id;
  @HiveField(4)
  String originalLanguage;
  @HiveField(5)
  String originalTitle;
  @HiveField(6)
  String overview;
  @HiveField(7)
  double popularity;
  @HiveField(8)
  String posterPath;
  @HiveField(9)
  String releaseDate;
  @HiveField(10)
  String title;
  @HiveField(11)
  bool video;
  @HiveField(12)
  double voteAverage;
  @HiveField(13)
  int voteCount;


}
