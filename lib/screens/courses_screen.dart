// lib/screens/courses_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final TextEditingController _urlController = TextEditingController();
  List<String> _videoTitles = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchPlaylistVideos() async {
    // --- IMPORTANT: Paste your API Key here ---
    final String apiKey = 'AIzaSyDpAEm4QqDPeCF2oAOJ8WfLiyv2k5BHbO0';
    // -----------------------------------------

    if (_urlController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _videoTitles = [];
    });

    try {
      // Extract the playlist ID from the URL
      final playlistId = _extractPlaylistId(_urlController.text);
      if (playlistId == null) {
        throw Exception('Invalid YouTube Playlist URL');
      }

      final url = Uri.parse(
          'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=$playlistId&key=$apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> titles = [];
        for (var item in data['items']) {
          titles.add(item['snippet']['title']);
        }
        setState(() {
          _videoTitles = titles;
        });
      } else {
        throw Exception('Failed to load playlist. Check your API key and URL.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _extractPlaylistId(String url) {
    if (!url.contains("list=")) return null;
    final uri = Uri.parse(url);
    return uri.queryParameters['list'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Courses'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Paste YouTube Playlist URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchPlaylistVideos,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Fetch Videos'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _videoTitles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(_videoTitles[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}