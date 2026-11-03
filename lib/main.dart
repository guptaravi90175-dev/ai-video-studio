
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const AIStudioApp());
}

class AIStudioApp extends StatelessWidget {
  const AIStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Video Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101018),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const EditorHome(),
    );
  }
}

class EditorHome extends StatefulWidget {
  const EditorHome({super.key});

  @override
  State<EditorHome> createState() => _EditorHomeState();
}

class _EditorHomeState extends State<EditorHome> {
  final ImagePicker picker = ImagePicker();
  VideoPlayerController? controller;
  bool loading = false;
  String videoName = 'No video selected';

  Future<void> importVideo() async {
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (file == null || !mounted) return;

    setState(() => loading = true);
    await controller?.dispose();

    final player = VideoPlayerController.file(File(file.path));

    try {
      await player.initialize();

      if (!mounted) {
        await player.dispose();
        return;
      }

      setState(() {
        controller = player;
        videoName = file.name;
        loading = false;
      });
    } catch (e) {
      await player.dispose();
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video error: $e')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI VIDEO STUDIO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Create Something Amazing',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            videoName,
            style: TextStyle(color: Colors.grey.shade400),
          ),

          const SizedBox(height: 18),

          Container(
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFF20202D),
              borderRadius: BorderRadius.circular(18),
            ),
            clipBehavior: Clip.antiAlias,
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : player != null && player.value.isInitialized
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: player.value.aspectRatio,
                              child: VideoPlayer(player),
                            ),
                          ),
                          IconButton.filled(
                            iconSize: 38,
                            onPressed: () {
                              setState(() {
                                if (player.value.isPlaying) {
                                  player.pause();
                                } else {
                                  player.play();
                                }
                              });
                            },
                            icon: Icon(
                              player.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 8,
                            child: VideoProgressIndicator(
                              player,
                              allowScrubbing: true,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.movie_creation_outlined,
                              size: 65,
                              color: Color(0xFFB99AFF),
                            ),
                            SizedBox(height: 12),
                            Text('Your Video Preview'),
                            Text('Import a video to start editing'),
                          ],
                        ),
                      ),
          ),

          const SizedBox(height: 18),

          FilledButton.icon(
            onPressed: loading ? null : importVideo,
            icon: const Icon(Icons.video_library),
            label: const Text('Import Video'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'EDITING TOOLS',
            style: TextStyle(
              color: Color(0xFFB99AFF),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: const [
              Tool(Icons.content_cut, 'Trim'),
              Tool(Icons.text_fields, 'Text'),
              Tool(Icons.music_note, 'Music'),
              Tool(Icons.auto_awesome, 'Effects'),
              Tool(Icons.filter, 'Filters'),
              Tool(Icons.subtitles, 'Captions'),
            ],
          ),

          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon'),
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Export Video'),
          ),

          const SizedBox(height: 15),

          Text(
            'Starter Version: Video import and preview are available. Editing and export tools will be added in future updates.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class Tool extends StatelessWidget {
  final IconData icon;
  final String name;

  const Tool(this.icon, this.name, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF20202D),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFB99AFF),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(name),
          const SizedBox(height: 4),
          const Text(
            'Coming Soon',
            style: TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
