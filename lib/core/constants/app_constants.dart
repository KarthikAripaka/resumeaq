class AppConstants {
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'llama-3.3-70b-versatile';
  static const String supabaseStorageBucket = 'resumes';
  static const int maxPdfSizeMb = 10;
  static const List<String> jobRoles = [
    'Flutter Developer',
    'Full Stack Developer',
    'Backend Engineer',
    'AI Engineer',
    'Data Analyst',
    'DevOps Engineer',
  ];
}