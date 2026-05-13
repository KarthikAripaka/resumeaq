import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_iq_ai/core/constants/app_constants.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  File? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeNotifierProvider);
    final selectedRole = ref.watch(selectedJobRoleNotifierProvider);

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
                          '${_selectedFile!.path.split('/').last} (${_selectedFile!.lengthSync()} bytes)')
                      : const Text('Drop PDF here or tap to select'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _selectedFile != null ? _analyze : null,
              child: const Text('Analyze Resume'),
            ),
            if (resumeState.isLoading) const CircularProgressIndicator(),
            if (resumeState.hasError) Text('Error: ${resumeState.error}'),
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }

  void _pickFile() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && mounted) {
      setState(() => _selectedFile = File(result.files.single.path!));
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
}
