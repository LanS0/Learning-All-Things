class PopularModel {
  String name;
  String path;

  PopularModel({
    required this.name,
    required this.path,
  });

  static List<PopularModel> getPopular() {
    List<PopularModel> populars = [];

    populars.add(
      PopularModel(
        name: 'Beauty and The Beast',
        path: 'assets/poster/bntb.jpg',
      )
    );

    populars.add(
      PopularModel(
        name: 'Harry Potter',
        path: 'assets/poster/hp.jpg',
      )
    );

    populars.add(
      PopularModel(
        name: 'Iron Man',
        path: 'assets/poster/iron_man.png',
      )
    );

    populars.add(
      PopularModel(
        name: 'Thor',
        path: 'assets/poster/thor.png',
      )
    );

    populars.add(
      PopularModel(
        name: 'Winnie The Pooh',
        path: 'assets/poster/wtp.jpg',
      )
    );

    return populars;
  }
  
}

class Video {
  String statusCode;
  String message;
  int total;
  int limit;
  List<VideoData> data;
  int current;
  int first;
  int last;
  int next;
  int prev;

  Video({
      required this.statusCode,
      required this.message,
      required this.total,
      required this.limit,
      required this.data,
      required this.current,
      required this.first,
      required this.last,
      required this.next,
      required this.prev,
  });

}

class VideoData {
  String id;
  String title;
  String description;
  String genre;
  String genreString;
  String irl;
  int year;
  int duration;
  bool isVIP;
  DateTime uploadAt;
  int total;

  VideoData({
      required this.id,
      required this.title,
      required this.description,
      required this.genre,
      required this.genreString,
      required this.irl,
      required this.year,
      required this.duration,
      required this.isVIP,
      required this.uploadAt,
      required this.total,
  });
}
