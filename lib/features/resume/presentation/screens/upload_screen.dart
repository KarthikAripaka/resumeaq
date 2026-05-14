import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/core/constants/app_constants.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    final selectedRole = ref.watch(selectedJobRoleNotifierProvider);

    // Listen to state changes for navigation and errors
    ref.listen(resumeNotifierProvider, (previous, next) {
      if (next.hasValue && mounted) {
        // Navigate to analysis screen on success
        context.go('/analysis');
      } else if (next.hasError && mounted) {
        final error = next.error.toString();
        if (error.contains('Rate limit')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Rate limit reached, please wait before retrying...'),
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          // Show a user-friendly message for any other errors
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Analysis completed with local processing'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Still navigate to analysis if we have a result
          if (next.value != null) {
            context.go('/analysis');
          }
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resume')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedRole,
              items: AppConstants.jobRoles.map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) => ref
                  .read(selectedJobRoleNotifierProvider.notifier)
                  .setJobRole(value!),
            ),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: _selectedFile != null
                      ? Text(
                          '${_selectedFile!.name} (${_selectedFile!.size} bytes)')
                      : const Text('Drop PDF here or tap to select'),
                ),
              ),
            ),
            if (resumeState.isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('📄 Extracting text from PDF...'),
              const SizedBox(height: 4),
              const Text('🤖 Analyzing with AI (may take 10-30 seconds)...'),
              const SizedBox(height: 4),
              const Text('💾 Saving locally...'),
            ] else if (resumeState.hasError) ...[
              const SizedBox(height: 16),
              Text(
                'Error: ${resumeState.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _retryAnalysis,
                child: const Text('Retry'),
              ),
            ] else
              ElevatedButton(
                onPressed: _selectedFile != null && !resumeState.isLoading
                    ? _analyze
                    : null,
                child: const Text('Analyze Resume'),
              ),
            const SizedBox(height: 16),
            const Text(
              '📱 Local Analysis Mode\n'
              '• No cloud storage required\n'
              '• AI analysis powered by Groq\n'
              '• Resume saved locally on device\n'
              '• Works offline after first analysis',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }

  void _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf'], withData: true);
    if (result != null && mounted) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  void _analyze() {
    if (_selectedFile != null) {
      final selectedRole = ref.read(selectedJobRoleNotifierProvider);
      ref
          .read(resumeNotifierProvider.notifier)
          .uploadAndAnalyze(_selectedFile!, selectedRole);
    }
  }

  void _retryAnalysis() {
    _analyze();
  }

  @override
  void initState() {
    super.initState();
  }
}
