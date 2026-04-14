import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eyz_movie/_baseUrl/baseUrl.dart';
import 'package:eyz_movie/models/listViewModel.dart';
import 'package:eyz_movie/pages/home/home.dart';
import 'package:eyz_movie/pages/membership/membership.dart';
import 'package:eyz_movie/pages/video/fullScreenVideo.dart';
import 'package:eyz_movie/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class DetailSeries extends StatefulWidget {
  final String id;

  const DetailSeries({required this.id, Key? key}) : super(key: key);

  @override
  State<DetailSeries> createState() => _DetailSeriesState();
}

class _DetailSeriesState extends State<DetailSeries> {
  Timer? _timer;
  late SharedPreferences storage;
  late Map<String, dynamic> vids;
  late List<dynamic> listSeries;

  bool isLoading = true;
  bool isLiked = false;
  bool isFavorited = false;

  late bool isUserVIP;
  late bool isSeries = false;
  VideoPlayerController? _controller;
  late Map<String, dynamic> video;
  var id;
  var thumbnail;
  var url;
  var description;
  var duration;
  var title;
  double _playbackSpeed = 1.0;

  void _startTimerAndShowDialog() {
    // Cancel timer sebelumnya (kalau ada)
    _timer?.cancel();

    _timer = Timer(const Duration(seconds: 10), () {
      // Pastikan widget masih mounted (tidak di-pop)
      if (mounted) {
        var stringUser = storage.getString("user");
        var data = jsonDecode(stringUser.toString());
        // print(data);
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
        //       title: const Text("Waktu Habis"),
        //       content: const Text("Sudah 10 detik berlalu!"),
        //       actions: [
        //         TextButton(
        //           onPressed: () => Navigator.pop(context),
        //           child: const Text("OK"),
        //         ),
        //       ],
        //     );
        //   },
        // );
      }
    });
  }

  Future<void> enterFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); // hide status bar
  }

  Future<void> exitFullScreen() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // show status bar
  }

  void _rewind() {
    final newPosition = _controller!.value.position - const Duration(seconds: 5);
    _controller?.seekTo(newPosition >= Duration.zero ? newPosition : Duration.zero);
  }

  void _forward() {
    final maxDuration = _controller!.value.duration;
    final newPosition = _controller!.value.position + const Duration(seconds: 5);
    _controller!.seekTo(newPosition <= maxDuration ? newPosition : maxDuration);
  }

  void _changeSpeed() {
    final newSpeed = _playbackSpeed == 2.0 ? 1.0 : _playbackSpeed + 0.5;
    _controller!.setPlaybackSpeed(newSpeed);
    setState(() {
      _playbackSpeed = newSpeed;
    });
  }

  void _getVideoByID(String id) async {
    var resp = await BaseClient().getVideoByID("/series", id);
    var dataJson = jsonDecode(resp);
    setState(() {
      if (dataJson != null) {
        if (dataJson['data']['id'] != '00000000-0000-0000-0000-000000000000') {
          // print('INI DATA JSON : $dataJson');
          video = dataJson['data'];
          id = video['id'];
          thumbnail = video['thumbnail'];
          url = video['url'];
          title = video['title'];
          description = video['description'];
          duration = video['duration'];
          
          listSeries = video['list_series'];

          _controller = VideoPlayerController.networkUrl(Uri.parse(
          video['url']))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {
              isLoading = false;
              vids = video;
              isSeries = true;
            });
          });
        }
      }
    });
  }

  Future<void> initStorage() async {
    storage = await SharedPreferences.getInstance();
    _getPrefs();

    final dir = await getApplicationDocumentsDirectory();
    // Simpan metadata ke file JSON
    final metadataFile = File("${dir.path}/favorite.json");
    List favorite = [];

    if (await metadataFile.exists()) {
      final content = await metadataFile.readAsString();
      favorite = jsonDecode(content);
    }

    if (favorite.isNotEmpty) {
      for (var i = 0; i < favorite.length; i++) {
        if (favorite[i]['id'] == widget.id) {
          isFavorited = true;
        }
      }
    }

    // Simpan metadata ke file JSON
    final metadataFileLike = File("${dir.path}/like.json");
    List Like = [];

    if (await metadataFile.exists()) {
      final content = await metadataFile.readAsString();
      Like = jsonDecode(content);
    }

    if (Like.isNotEmpty) {
      for (var i = 0; i < Like.length; i++) {
        if (Like[i]['id'] == widget.id) {
          isLiked = true;
        }
      }
    }
  }

  
  void _getPrefs() async {
    var stringUser = storage.getString("user");
    var data = jsonDecode(stringUser.toString());
    setState(() {
      isUserVIP = data['is_v_i_p'];
      if (data['liked'] != null) {
        vids = data['liked'];
      }
    });
  }
  
  @override
  void initState() {
    initStorage();
    _getVideoByID(widget.id);
    super.initState();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller!.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading ? Consumer<ThemeProvider>(
      builder: (context, ThemeProvider notifier, child) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // _topBar(),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            true,
                          );
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text('Back'),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        title ?? 'No Title',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30,),
                      _controller!.value.isInitialized
                      ? videoPage(context)
                      : Container(),
                      listSeries.isEmpty ?
                      Row(
                        children: [
                          Column(
                            children: [
                              Container(
                              height: 150,
                              child: ListView.separated(
                                itemCount: listSeries.length,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                ),
                                separatorBuilder: (context, index) => SizedBox(width: 25, ),
                                itemBuilder: (context, index) {
                                  print(listSeries[index]);
                                  var vids = listSeries[index] as Map<String, dynamic>;
                                  return Container(
                                    width: 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(0),
                                          child: GestureDetector(
                                            onTap: () => {
                                              vids['is_v_i_p'] && !isUserVIP ?
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false, // klik di luar modal tidak menutup
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    content: Text("Apakah Anda ingin Berlangganan untuk Melanjutkan?"),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // Tutup modal
                                                        },
                                                        child: Text("Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context); // Tutup modal
                                                          // Aksi "Go" di sini
                                                          // print("Go ditekan!");
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => Membership(),
                                                            ),
                                                          );
                                                        },
                                                        child: Text("Langganan"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              )
                                              :
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DetailSeries(id: vids['id'].toString()),
                                                ),
                                              ).then((result) {
                                                if (result == true) {
                                                  initStorage();
                                                }
                                              })
                                            },
                                            child: Card(
                                              clipBehavior: Clip.antiAlias,
                                              elevation: 10,
                                              // color: Colors.blue.shade300,
                                              child: Stack(
                                                alignment: Alignment.bottomCenter,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(vids['title']),
                                                      Text(
                                                        '${_formatDuration(vids['duration'])}',
                                                        style: TextStyle(fontSize: 15, color: Colors.white),
                                                      ),
                                                    ]
                                                  )
                                                ],
                                              )
                                            ),
                                          )
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                            ],
                          )
                        ],
                      )
                      :
                      Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // 👍 Like Button
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                initStorage();
                                isLiked = !isLiked;
                                print(listSeries);
                                LikeVideo(vids['id'], url.toString(), thumbnail.toString(), duration.toString(), description.toString(), !isLiked, vids['title'], vids['is_v_i_p']);
                              });
                            },
                          ),

                          // ❤️ Favorite Button
                          IconButton(
                            icon: Icon(
                              isFavorited ? Icons.favorite : Icons.favorite_border,
                              color: isFavorited ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              initStorage();
                              setState(() {
                                FavoriteVideo(vids['id'], url.toString(), thumbnail.toString(), duration.toString(), description.toString(), !isFavorited, vids['title'], vids['is_v_i_p']);
                                isFavorited = !isFavorited;
                              });
                            },
                          ),

                          // Download Button
                          IconButton(
                            icon: Icon(
                              Icons.download,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              !isUserVIP ?
                              showDialog(
                                context: context,
                                barrierDismissible: false, // klik di luar modal tidak menutup
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Text("Apakah Anda ingin Berlangganan untuk Melanjutkan?"),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Tutup modal
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Tutup modal
                                          // Aksi "Go" di sini
                                          // print("Go ditekan!");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Membership(),
                                            ),
                                          );
                                        },
                                        child: Text("Langganan"),
                                      ),
                                    ],
                                  );
                                },
                              )
                              :
                              downloadVideo(vids['id'], url, vids['title'], description, duration, thumbnail);
                              // print('hey');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(description ?? 'No Description'),
                      SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _controller!.value.isPlaying
                    ? _controller!.pause()
                    : _controller!.play();
              });
            },
            child: Icon(
              _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        );
      }
    )
    :
    Center(child: CircularProgressIndicator());
  }

  Stack videoPage(BuildContext context) {
    return Stack(
      children: [
        // Video Player
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),

        // Overlay gelap
        Container(
          color: Colors.black.withOpacity(0.3),
        ),

        // // Tombol play/pause di tengah
        // Center(
        //   child: IconButton(
        //     iconSize: 64,
        //     color: Colors.white,
        //     icon: Icon(
        //       _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
        //     ),
        //     onPressed: () {
        //       setState(() {
        //         _controller!.value.isPlaying
        //             ? _controller!.pause()
        //             : _controller!.play();
        //       });
        //     },
        //   ),
        // ),

        // Progress bar di bawah
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _controller!,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black26,
            ),
          ),
        ),

        // Kontrol rewind, play/pause, forward, speed (tengah bawah)
        Padding(
          padding: const EdgeInsets.only(top: 112.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.replay_5, color: Colors.white),
                onPressed: _rewind,
              ),
              // IconButton(
              //   icon: Icon(
              //     _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
              //     color: Colors.white,
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              //     });
              //   },
              // ),
              IconButton(
                iconSize: 48,
                color: Colors.white,
                icon: Icon(
                  _controller!.value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                ),
                onPressed: () {
                  _startTimerAndShowDialog();
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.forward_5, color: Colors.white),
                onPressed: _forward,
              ),
            ],
          ),
        ),

        // Durasi (pojok kiri atas)
        Positioned(
          bottom: 8,
          left: 8,
          child: Text(
            '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
            style: TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),

        // Tombol fullscreen (pojok kanan bawah)
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            children: [
            TextButton(
              onPressed: _changeSpeed,
              child: Text('${_playbackSpeed}x', style: TextStyle(color: Colors.white)),
            ),
              IconButton(
                icon: Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () async {
                  await enterFullScreen();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenVideoPage(controller: _controller!),
                    ),
                  ).then((_) async {
                    await exitFullScreen();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> FavoriteVideo(String id, String url, String thumbnail, String duration, String description, bool isFavorite, String title, bool isVIP) async {
  final dir = await getApplicationDocumentsDirectory();

  // Simpan metadata ke file JSON
  final metadataFile = File("${dir.path}/favorite.json");
  List favorite = [];

  if (await metadataFile.exists()) {
    final content = await metadataFile.readAsString();
    favorite = jsonDecode(content);
  }
  if (isFavorite) {
    favorite.add({
      "id": id,
      "is_video": false,
      "is_series": true,
      "title": title,
      "is_v_i_p": isVIP,
      "thumbnail": thumbnail,
      "duration": duration,
      "description": description,
    });
  } else {
    for (var i = 0; i < favorite.length; i++) {
      if (favorite[i]['id'] == id) {
        favorite.removeAt(i);
        break;
      }
    }
  }

  await metadataFile.writeAsString(jsonEncode(favorite));

  // print("Video dan metadata tersimpan.");
}

Future<void> LikeVideo(String id, String url, String thumbnail, String duration, String description, bool isLiked, String title, bool isVIP) async {
  final dir = await getApplicationDocumentsDirectory();

  // Simpan metadata ke file JSON
  final metadataFile = File("${dir.path}/like.json");
  List like = [];

  if (await metadataFile.exists()) {
    final content = await metadataFile.readAsString();
    like = jsonDecode(content);
  }
  if (isLiked) {
    like.add({
      "id": id,
      "title": title,
      "is_v_i_p": isVIP,
      "thumbnail": thumbnail,
      "duration": duration,
      "description": description,
    });
  } else {
    like.removeAt(like.indexOf(id));
  }

  await metadataFile.writeAsString(jsonEncode(like));
}

Future<void> downloadVideo(String id, String url, String title, String description, int duration, String thumbnail) async {
  final dir = await getApplicationDocumentsDirectory();
  final savePath = "${dir.path}/$title.mp4";
  final savePathImage = "${dir.path}/$thumbnail.png";

  // Download video
  await Dio().download(url, savePath);
  await Dio().download(url, savePathImage);

  // Simpan metadata ke file JSON
  final metadataFile = File("${dir.path}/download.json");
  List videos = [];

  if (await metadataFile.exists()) {
    final content = await metadataFile.readAsString();
    videos = jsonDecode(content);
  }

  videos.add({
    "id": id,
    "title": title,
    "thumbnail": savePathImage,
    "duration": duration,
    "description": description,
    "path": savePath
  });

  await metadataFile.writeAsString(jsonEncode(videos));

  // print("Video dan metadata tersimpan.");
}

Future<void> deleteVideo(String videoPath) async {
  final dir = await getApplicationDocumentsDirectory();
  final metadataFile = File("${dir.path}/download.json");

  // 1. Hapus file video
  final videoFile = File(videoPath);
  if (await videoFile.exists()) {
    await videoFile.delete();
    // print("Video dihapus: $videoPath");
  }

  // 2. Hapus metadata di JSON
  if (await metadataFile.exists()) {
    final content = await metadataFile.readAsString();
    List videos = jsonDecode(content);

    videos.removeWhere((video) => video['path'] == videoPath);

    await metadataFile.writeAsString(jsonEncode(videos));
    // print("Metadata dihapus.");
  }
}