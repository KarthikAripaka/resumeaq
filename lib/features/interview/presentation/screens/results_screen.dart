import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:interview_iq_ai/features/analytics/presentation/providers/analytics_provider.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionHistory = ref.watch(sessionHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: sessionHistory.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.assignment,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No interview results yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete your first interview to see results here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/interview'),
                            icon: const Icon(Icons.forum),
                            label: const Text('Start Interview'),
                          ),
                        ],
                      ),
                    );
                  }

                  final latestSession = sessions.first;
                  final feedbacks = latestSession.feedbacks.values.toList();

                  if (feedbacks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.incomplete_circle,
                            size: 64,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Interview in progress',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Complete your answers to see detailed results',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.go('/interview'),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Continue Interview'),
                          ),
                        ],
                      ),
                    );
                  }

                  final overallScore = feedbacks.map((f) => f.score).reduce((a, b) => a + b) / feedbacks.length;

                  // Trigger confetti for good scores
                  if (overallScore >= 8.0) {
                    _confettiController.play();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overall Score Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: overallScore >= 8.0
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : overallScore >= 6.0
                                    ? [Colors.blue.shade400, Colors.blue.shade600]
                                    : [Colors.orange.shade400, Colors.orange.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '${overallScore.toStringAsFixed(1)}/10',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              overallScore >= 8.0
                                  ? 'Excellent Performance!'
                                  : overallScore >= 6.0
                                      ? 'Good Performance'
                                      : 'Keep Practicing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${latestSession.jobRole} Interview',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Performance Breakdown Chart
                      const Text(
                        'Performance Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 10,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const categories = ['HR', 'Technical', 'DSA', 'Project'];
                                    if (value.toInt() < categories.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          categories[value.toInt()],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: _generateBarGroups(feedbacks),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Detailed Feedback
                      const Text(
                        'Detailed Feedback',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: feedbacks.length,
                        itemBuilder: (context, index) {
                          final feedback = feedbacks[index];
                          final question = latestSession.questions.firstWhere(
                            (q) => latestSession.feedbacks.containsKey(q.id),
                            orElse: () => latestSession.questions[index],
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getScoreColor(feedback.score.toDouble()),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                        child: Text(
                                          '${feedback.score}/10',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                    color: _getScoreColor(feedback.score.toDouble()),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          question.category,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    question.question,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildFeedbackSection('Correctness', feedback.correctness),
                                  const SizedBox(height: 8),
                                  _buildFeedbackSection('Communication', feedback.communication),
                                  if (feedback.confidenceTip.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildFeedbackSection('Confidence Tip', feedback.confidenceTip),
                                  ],
                                  if (feedback.idealAnswerHints.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    _buildFeedbackSection('Ideal Answer Hints', feedback.idealAnswerHints),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => context.go('/interview'),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Practice Again'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => context.go('/analytics'),
                              icon: const Icon(Icons.analytics),
                              label: const Text('View Analytics'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(sessionHistoryProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate().fadeIn().slideY(),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<dynamic> feedbacks) {
    final categoryScores = <String, List<double>>{
      'hr': [],
      'technical': [],
      'dsa': [],
      'project': [],
    };

    // Group scores by category (simplified - in real app, this would be more sophisticated)
    for (final feedback in feedbacks) {
      final category = feedbacks.indexOf(feedback) % 4; // Simple distribution
      switch (category) {
        case 0:
          categoryScores['hr']!.add(feedback.score.toDouble());
          break;
        case 1:
          categoryScores['technical']!.add(feedback.score.toDouble());
          break;
        case 2:
          categoryScores['dsa']!.add(feedback.score.toDouble());
          break;
        case 3:
          categoryScores['project']!.add(feedback.score.toDouble());
          break;
      }
    }

    final categories = ['hr', 'technical', 'dsa', 'project'];
    return List.generate(categories.length, (index) {
      final category = categories[index];
      final scores = categoryScores[category]!;
      final avgScore = scores.isNotEmpty ? scores.reduce((a, b) => a + b) / scores.length : 0.0;

      return           BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: avgScore.toDouble(),
            color: _getScoreColor(avgScore),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return Colors.green.shade600;
    if (score >= 6.0) return Colors.blue.shade600;
    return Colors.orange.shade600;
  }

  Widget _buildFeedbackSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _shareResults() async {
    final sessionHistory = ref.read(sessionHistoryProvider);
    if (sessionHistory.valueOrNull == null || sessionHistory.value!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results to share')),
      );
      return;
    }

    final latestSession = sessionHistory.value!.first;
    final feedbacks = latestSession.feedbacks.values.toList();

    if (feedbacks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete your interview first')),
      );
      return;
    }

    final overallScore = feedbacks.map((f) => f.score).reduce((a, b) => a + b) / feedbacks.length;

    final shareText = '''
🎯 InterviewIQ AI - Interview Results

📊 Overall Score: ${overallScore.toStringAsFixed(1)}/10
🎯 Role: ${latestSession.jobRole}
📅 Date: ${latestSession.startedAt.toString().split('.')[0]}

📈 Performance Summary:
${feedbacks.length} questions answered
${feedbacks.where((f) => f.score >= 7).length} strong responses
${feedbacks.where((f) => f.score >= 5 && f.score < 7).length} good responses

💡 Key Strengths:
${feedbacks.where((f) => f.score >= 7).map((f) => '• ${f.correctness.split('.')[0]}').take(3).join('\n')}

🔧 Areas to Improve:
${feedbacks.where((f) => f.score < 7).map((f) => '• ${f.correctness.split('.')[0]}').take(3).join('\n')}

🚀 Next Steps:
Continue practicing with InterviewIQ AI for better results!

#InterviewPrep #InterviewIQ #CareerGrowth
    '''.trim();

    try {
      await Share.share(
        shareText,
        subject: 'My InterviewIQ AI Results - ${latestSession.jobRole}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }
}