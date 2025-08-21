import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bad Movie Plots',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const QuizPage(),
    const AboutPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> _plots = [];
  int _currentIndex = 0;
  bool _showAnswer = false;
  static const String _progressKey = 'quiz_progress';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString = await rootBundle.loadString('assets/reddit_posts_top_comment.json');
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    final prefs = await SharedPreferences.getInstance();
    final savedProgress = prefs.getInt(_progressKey) ?? 0;
    setState(() {
      _plots = data;
      _currentIndex = savedProgress < data.length ? savedProgress : 0;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_progressKey, _currentIndex);
  }

  void _reveal() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _previous() {
    if (_plots.isEmpty) return;
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex - 1 + _plots.length) % _plots.length;
    });
    _saveProgress();
  }

  void _next() {
    if (_plots.isEmpty) return;
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex + 1) % _plots.length;
    });
    _saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool loading = _plots.isEmpty;
    final Map<String, dynamic>? current = !loading ? _plots[_currentIndex] as Map<String, dynamic> : null;
    final String question = current != null ? (current['question'] as String? ?? '') : '';
    final String answer = current != null ? (current['answer'] as String? ?? '') : '';
    final String category = current != null ? (current['category'] as String? ?? '') : '';
    final String upvotes = current != null ? (current['upvotes'] as String? ?? '') : '';

    final gradients = Theme.of(context).extension<AppGradients>();
    final colorScheme = theme.colorScheme;

    return Scaffold(
  appBar: AppBar(
    title: const Text('Bad Movie Plots'),
    elevation: 0,
    backgroundColor: Colors.transparent,
  ),
  body: Container(
    decoration: BoxDecoration(
      gradient: gradients?.backgroundGradient,
    ),
    child: SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress (compact)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${_currentIndex + 1}/${_plots.length}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (_currentIndex + 1) / _plots.length,
                              minHeight: 6,
                              backgroundColor: Colors.white24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Plot Card (smaller)
                  Card(
                    elevation: 6,
                    margin: EdgeInsets.zero,
                    shadowColor: Colors.black.withOpacity(0.1),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.28, // reduced
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.movie, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Plot',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              question,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.4,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Buttons (compact)
                  Row(
  children: [
    Expanded(
      flex: 2, // smaller
      child: OutlinedButton.icon(
        onPressed: _previous,
        icon: const Icon(Icons.arrow_back),
        label: const Text(''),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      flex: 4, // bigger space for Reveal
      child: ElevatedButton.icon(
        onPressed: _reveal,
        icon: const Icon(Icons.lightbulb),
        label: const Text('Reveal'),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      flex: 2, // smaller
      child: OutlinedButton.icon(
        onPressed: _next,
        icon: const Icon(Icons.arrow_forward),
        label: const Text(''),
      ),
    ),
  ],
),

                  const SizedBox(height: 12),

                  // Answer area (fixed height, fade in/out)
                  AnimatedOpacity(
  opacity: _showAnswer ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 300),
  child: Card(
    elevation: 6,
    shadowColor: Colors.black.withOpacity(0.1),
    color: Colors.green[50],
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 👈 shrink to fit content
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, size: 18, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text(
                'Answer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            child: Text(
              answer,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.4,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
],
              ),
            ),
    ),
  ),
);

  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = Theme.of(context).extension<AppGradients>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: gradients?.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // App Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.movie,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                // App Name
                Text(
                  'Bad Movie Plots',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Version
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 0.0.1',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'About',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'A fun quiz app featuring badly explained movie plots from Reddit. '
                          'Test your movie knowledge by guessing the film from these hilariously '
                          'misleading descriptions!',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Footer
                Text(
                  'Made with ❤️ using Flutter',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
