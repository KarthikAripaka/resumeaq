import 'package:flutter/material.dart';
import '../../features/interview/domain/models/interview_models.dart';

class QuestionCard extends StatelessWidget {
  final InterviewQuestion question;
  final int number;
  final int total;

  const QuestionCard({
    super.key,
    required this.question,
    required this.number,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    switch (question.category) {
      case 'hr':
        badgeColor = Colors.blue;
        break;
      case 'technical':
        badgeColor = Colors.purple;
        break;
      case 'dsa':
        badgeColor = Colors.orange;
        break;
      case 'project':
        badgeColor = Colors.teal;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(question.category.toUpperCase()),
                  backgroundColor: badgeColor.withOpacity(0.1),
                  labelStyle: TextStyle(color: badgeColor),
                ),
                const Spacer(),
                Text('Question $number of $total'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.question,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}