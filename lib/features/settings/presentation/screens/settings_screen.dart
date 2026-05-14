import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:interview_iq_ai/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:interview_iq_ai/core/providers/service_providers.dart';

class _LocalUser {
  final String email;

  const _LocalUser({required this.email});

  String get id => 'local_user';
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Offline-friendly: SharedPreferences removed.
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = true;
      _darkModeEnabled = false;
      _autoSaveEnabled = true;
      _selectedLanguage = 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    // No-op in offline mode (SharedPreferences removed).
  }

  Future<void> _exportUserData() async {
    try {
      const user = _LocalUser(email: 'guest@example.com');
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to export data')),
        );
        return;
      }

      final statsAsync = ref.read(userStatsProvider);
      final historyAsync = ref.read(sessionHistoryProvider);

      final stats = statsAsync.valueOrNull ??
          {
            'avgAtsScore': 0.0,
            'totalSessions': 0,
            'bestScore': 0,
          };
      final sessions = historyAsync.valueOrNull ?? [];

      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'userId': user.id,
        'userEmail': user.email,
        'statistics': {
          'averageAtsScore': stats['avgAtsScore'],
          'totalSessions': stats['totalSessions'],
          'bestScore': stats['bestScore'],
        },
        'interviewSessions': sessions.map((session) {
          return {
            'id': session.id,
            'jobRole': session.jobRole,
            'startedAt': session.startedAt.toIso8601String(),
            'questionsCount': session.questions.length,
            'answersCount': session.feedbacks.length,
            'averageScore': session.feedbacks.isNotEmpty
                ? session.feedbacks.values
                        .map((f) => f.score)
                        .reduce((a, b) => a + b) /
                    session.feedbacks.length
                : 0.0,
            'feedbacks': session.feedbacks.map((questionId, feedback) {
              return MapEntry(questionId, {
                'score': feedback.score,
                'correctness': feedback.correctness,
                'communication': feedback.communication,
                'confidenceTip': feedback.confidenceTip,
                'idealAnswerHints': feedback.idealAnswerHints,
                'followUpQuestion': feedback.followUpQuestion,
              });
            }),
          };
        }).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'interview_iq_data_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'InterviewIQ AI Data Export',
        text: 'My interview preparation data from InterviewIQ AI',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully as $fileName'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Getting Started',
                '1. Upload your resume using the Upload tab\n'
                    '2. Wait for AI analysis (10-30 seconds)\n'
                    '3. Review your ATS score and recommendations\n'
                    '4. Practice interviews in the Interview tab',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Resume Analysis',
                '• ATS Score: How well your resume matches job requirements\n'
                    '• Strengths: What\'s working well\n'
                    '• Missing Skills: Areas to add\n'
                    '• Recommendations: Specific improvements',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Interview Practice',
                '• Answer questions within the time limit\n'
                    '• Use voice recording for natural responses\n'
                    '• Get AI feedback on your answers\n'
                    '• Review results and improvement tips',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Analytics',
                '• Track your progress over time\n'
                    '• View performance trends\n'
                    '• Compare scores across interviews\n'
                    '• Identify areas for improvement',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final feedbackController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Feedback'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How would you rate your experience?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() => rating = index + 1);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feedbackController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tell us what you think...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy for InterviewIQ AI\n\n'
            'Effective Date: January 1, 2024\n\n'
            '1. Information We Collect\n'
            '• Resume files uploaded for analysis\n'
            '• Interview responses and feedback\n'
            '• Usage analytics and performance metrics\n'
            '• Account information (email, profile data)\n\n'
            '2. How We Use Your Information\n'
            '• To provide AI-powered resume analysis\n'
            '• To generate personalized interview questions\n'
            '• To deliver feedback and improvement suggestions\n'
            '• To improve our services and user experience\n\n'
            '3. Data Security\n'
            '• All data is encrypted in transit and at rest\n'
            '• We use industry-standard security measures\n'
            '• Data is processed securely and not shared with third parties\n\n'
            '4. Your Rights\n'
            '• You can export your data at any time\n'
            '• You can delete your account and all associated data\n'
            '• You control what information you share\n\n'
            '5. Contact Us\n'
            'For privacy concerns, contact us at privacy@interviewiq.ai',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service for InterviewIQ AI\n\n'
            'Effective Date: January 1, 2024\n\n'
            '1. Acceptance of Terms\n'
            'By using InterviewIQ AI, you agree to these terms.\n\n'
            '2. Description of Service\n'
            'InterviewIQ AI provides AI-powered interview preparation tools including resume analysis and mock interviews.\n\n'
            '3. User Responsibilities\n'
            '• Provide accurate information\n'
            '• Use the service for lawful purposes\n'
            '• Respect intellectual property rights\n'
            '• Maintain account security\n\n'
            '4. Service Availability\n'
            'We strive for high availability but cannot guarantee uninterrupted service.\n\n'
            '5. Intellectual Property\n'
            'All content, features, and functionality are owned by InterviewIQ AI and protected by copyright laws.\n\n'
            '6. Limitation of Liability\n'
            'InterviewIQ AI is provided "as is" without warranties. We are not liable for any damages.\n\n'
            '7. Termination\n'
            'We may terminate or suspend your account for violations of these terms.\n\n'
            '8. Changes to Terms\n'
            'We may update these terms with notice to users.\n\n'
            'For questions, contact us at support@interviewiq.ai',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                _saveSetting('language', value);
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Spanish'),
              value: 'Spanish',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() => _selectedLanguage = value!);
                _saveSetting('language', value);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Language switching coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const user = _LocalUser(email: 'guest@example.com');

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(user?.email ?? 'Guest User'),
                        subtitle: const Text('Account email'),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Account Details'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Account details coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle:
                          const Text('Receive interview reminders and updates'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                        _saveSetting('notifications_enabled', value);
                      },
                      secondary: const Icon(Icons.notifications),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Use dark theme for the app'),
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() => _darkModeEnabled = value);
                        _saveSetting('dark_mode_enabled', value);
                        ref.read(themeModeProvider.notifier).setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Switched to ${value ? 'dark' : 'light'} theme'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      secondary: const Icon(Icons.dark_mode),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Auto-save Progress'),
                      subtitle:
                          const Text('Automatically save interview progress'),
                      value: _autoSaveEnabled,
                      onChanged: (value) {
                        setState(() => _autoSaveEnabled = value);
                        _saveSetting('auto_save_enabled', value);
                      },
                      secondary: const Icon(Icons.save),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(_selectedLanguage),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showLanguageDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Data & Privacy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: _showPrivacyPolicy,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: _showTermsOfService,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Export Data'),
                      subtitle: const Text('Download your interview data'),
                      onTap: _exportUserData,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showHelpDialog,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text('Send Feedback'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showFeedbackDialog,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.contact_support),
                      title: const Text('Contact Support'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Contact support coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'App Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.info),
                      title: Text('Version'),
                      subtitle: Text('1.0.0'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Clear Cache'),
                      subtitle: const Text('Free up storage space'),
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Clear Cache'),
                            content: const Text(
                                'This will remove all locally stored data. Continue?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await Hive.deleteFromDisk();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cache cleared successfully')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.red.shade50,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red.shade600),
                  title: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      // No auth to sign out
                      if (!mounted) return;
                      context.go('/auth');
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ).animate().fadeIn().slideY(),
      ),
    );
  }
}
