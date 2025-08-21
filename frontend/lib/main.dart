import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String jsonString = await rootBundle.loadString('assets/reddit_posts_top_comment.json');
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;
    setState(() {
      _plots = data;
      _currentIndex = 0;
    });
  }

  void _reveal() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _next() {
    if (_plots.isEmpty) return;
    setState(() {
      _showAnswer = false;
      _currentIndex = (_currentIndex + 1) % _plots.length;
    });
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
                      // Progress
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: LinearProgressIndicator(
                                value: (_currentIndex + 1) / _plots.length,
                                minHeight: 10,
                                backgroundColor: Colors.white24,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_currentIndex + 1}/${_plots.length}',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Card with plot
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Plot', style: theme.textTheme.titleMedium),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      category,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(question, style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.thumb_up,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    upvotes,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Buttons
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _reveal,
                            child: const Text('Reveal'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _next,
                            child: const Text('Next'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Animated answer
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Answer', style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                Text(answer, style: theme.textTheme.bodyLarge),
                              ],
                            ),
                          ),
                        ),
                        crossFadeState: _showAnswer ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 250),
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
