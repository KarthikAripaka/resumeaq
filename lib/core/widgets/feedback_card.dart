import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/interview/domain/models/interview_models.dart';

class FeedbackCard extends StatelessWidget {
  final AnswerFeedback feedback;

  const FeedbackCard({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    Color scoreColor;
    if (feedback.score >= 8) {
      scoreColor = Colors.green;
    } else if (feedback.score >= 5) {
      scoreColor = Colors.amber;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Correctness: ${feedback.correctness}'),
                const SizedBox(height: 8),
                Text('Communication: ${feedback.communication}'),
                const SizedBox(height: 8),
                Text('Confidence Tip: ${feedback.confidenceTip}'),
                ExpansionTile(
                  title: const Text('Ideal Answer Hints'),
                  children: [
                    Text(feedback.idealAnswerHints),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Follow-up: ${feedback.followUpQuestion}',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Chip(
                label: Text('${feedback.score}/10'),
                backgroundColor: scoreColor.withOpacity(0.1),
                labelStyle: TextStyle(color: scoreColor),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0);
  }
}