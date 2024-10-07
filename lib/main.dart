import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LyricsGenerator(),
    );
  }
}

class LyricsGenerator extends StatefulWidget {
  @override
  _LyricsGeneratorState createState() => _LyricsGeneratorState();
}

class _LyricsGeneratorState extends State<LyricsGenerator>
    with SingleTickerProviderStateMixin {
  final TextEditingController languageController = TextEditingController();
  final TextEditingController genreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController lyricsController = TextEditingController();

  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _titleFadeAnimation;

  List<String> quotes = [
    '"Music is the universal language of mankind."',
    '"Music is the strongest form of magic."'
  ];

  int _currentQuoteIndex = 0;
  bool _showQuotes = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),  // Set to 10 seconds
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: Colors.black,
      end: Colors.grey[850],
    ).animate(_controller);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Creating a sequence of color transitions for the title
    _titleFadeAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.red, end: Colors.blue),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.blue, end: Colors.green),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.green, end: Colors.yellow),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: ColorTween(begin: Colors.yellow, end: Colors.red),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % quotes.length;
      });
    });

    Future.delayed(Duration(seconds: 10), () {
      setState(() {
        _showQuotes = false;
      });
      _timer.cancel();
    });
  }

  Future<void> generateLyrics(String description) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.56.1:5000/generate_lyrics'), // Use your IP address
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'description': description}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          lyricsController.text = data['lyrics'] ?? 'No lyrics generated';  // Handle null value
        });
      } else {
        setState(() {
          lyricsController.text = 'Failed to generate lyrics: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        lyricsController.text = 'Error occurred: $e';  // Handle exceptions
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: AnimatedBuilder(
              animation: _titleFadeAnimation,
              builder: (context, child) {
                return Text(
                  'FENQITHO LYRICS GENERATOR',
                  style: TextStyle(
                    color: _titleFadeAnimation.value,  // Set animated color here
                    fontSize: 24,
                  ),
                );
              },
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),  // About icon
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('About'),
                      content: Text(
                        'Fenqitho is a harmonious symphony of technology and creativity, '
                        'where melodies are born from the union of code and art.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Language', icon: Icon(Icons.language, color: Colors.white)),
              Tab(text: 'Genre', icon: Icon(Icons.music_note, color: Colors.white)),
              Tab(text: 'Lyrics', icon: Icon(Icons.format_quote, color: Colors.white)),
            ],
          ),
          backgroundColor: Colors.black,
        ),
        body: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return Container(
              color: _colorAnimation.value,
              child: Stack(
                children: [
                  TabBarView(
                    children: [
                      // Language tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: languageController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter Language',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Genre Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: genreController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Enter Genre',
                            labelStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Lyrics Tab
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: descriptionController,
                                maxLines: 10, // Decreased size of description box
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Describe the song you would like to produce',
                                  labelStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                generateLyrics(descriptionController.text.trim());  // Trim input to avoid leading/trailing spaces
                              },
                              child: Text('Create/Update Lyrics'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Set button background color
                                foregroundColor: Colors.black, // Set button text color
                              ),
                            ),
                            SizedBox(height: 16),
                            Expanded(
                              child: TextField(
                                controller: lyricsController,
                                maxLines: 10, // Increased size of generated lyrics box
                                readOnly: true,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Generated Lyrics',
                                  labelStyle: TextStyle(color: Colors.white),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_showQuotes)
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          quotes[_currentQuoteIndex],
                          style: TextStyle(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Text(
                      'Created by Alwin George',
                      style: TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
