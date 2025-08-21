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
      home: const QuizPage(),
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
    final String title = current != null ? (current['title'] as String? ?? '') : '';
    final String answer = current != null ? ((current['top_comment'] as Map<String, dynamic>?)?['body'] as String? ?? '') : '';

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
                              Text('Plot', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(title, style: theme.textTheme.bodyLarge),
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
