
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';

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

class EditorHome extends StatelessWidget {
  const EditorHome({super.key});

  Future<void> importVideo(BuildContext context) async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (file == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrimScreen(
          videoFile: File(file.path),
          fileName: file.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI VIDEO STUDIO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Create Something Amazing',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: const Color(0xFF20202D),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_creation_outlined,
                  size: 65,
                  color: Color(0xFFB99AFF),
                ),
                SizedBox(height: 12),
                Text('Your Video Workspace'),
                Text('Import a video to start editing'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => importVideo(context),
            icon: const Icon(Icons.video_library),
            label: const Text('Import Video'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(55),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'EDITING TOOLS',
            style: TextStyle(
              color: Color(0xFFB99AFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.content_cut),
            title: Text('Trim & Cut'),
            subtitle: Text('Video trimming available'),
          ),
          const ListTile(
            leading: Icon(Icons.text_fields),
            title: Text('Text & Titles'),
            subtitle: Text('Coming Soon'),
          ),
          const ListTile(
            leading: Icon(Icons.music_note),
            title: Text('Music & Audio'),
            subtitle: Text('Coming Soon'),
          ),
          const ListTile(
            leading: Icon(Icons.auto_awesome),
            title: Text('Effects & Filters'),
            subtitle: Text('Coming Soon'),
          ),
        ],
      ),
    );
  }
}

class TrimScreen extends StatefulWidget {
  final File videoFile;
  final String fileName;

  const TrimScreen({
    super.key,
    required this.videoFile,
    required this.fileName,
  });

  @override
  State<TrimScreen> createState() => _TrimScreenState();
}

class _TrimScreenState extends State<TrimScreen> {
  final Trimmer trimmer = Trimmer();

  double startValue = 0;
  double endValue = 100;

  bool isPlaying = false;
  bool loading = true;
  bool saving = false;

  String? savedPath;

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  Future<void> loadVideo() async {
    try {
      await trimmer.loadVideo(videoFile: widget.videoFile);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video load error: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> saveVideo() async {
    setState(() => saving = true);

    try {
      final output = await trimmer.saveTrimmedVideo(
        startValue: startValue,
        endValue: endValue,
      );

      if (!mounted) return;

      setState(() => savedPath = output);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            output == null
                ? 'Video save nahi hua'
                : 'Trimmed video saved!',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trim Video'),
        actions: [
          TextButton(
            onPressed: loading || saving ? null : saveVideo,
            child: saving
                ? const CircularProgressIndicator()
                : const Text('SAVE'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(widget.fileName),
                ),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    child: VideoViewer(trimmer: trimmer),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Select the video section to keep'),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TrimViewer(
                    trimmer: trimmer,
                    viewerHeight: 55,
                    viewerWidth:
                        MediaQuery.of(context).size.width - 24,
                    maxVideoLength: const Duration(minutes: 10),
                    onChangeStart: (value) {
                      startValue = value;
                    },
                    onChangeEnd: (value) {
                      endValue = value;
                    },
                    onChangePlaybackState: (value) {
                      setState(() => isPlaying = value);
                    },
                  ),
                ),
                IconButton.filled(
                  iconSize: 38,
                  onPressed: () async {
                    final result =
                        await trimmer.videoPlaybackControl(
                      startValue: startValue,
                      endValue: endValue,
                    );
                    if (mounted) {
                      setState(() => isPlaying = result);
                    }
                  },
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                if (savedPath != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Saved: $savedPath',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 15),
              ],
            ),
    );
  }
}
