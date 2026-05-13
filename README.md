# InterviewIQ AI

AI-powered interview preparation app that analyzes resumes, generates personalized mock interviews, and provides real-time feedback using Google Gemini AI.

## Features

- **Resume Analysis**: Upload PDF resumes and get ATS scores, strengths/weaknesses, missing skills, and improvement tips
- **Mock Interviews**: AI-generated interview questions based on your resume and job role
- **Real-time Feedback**: Instant evaluation of answers with scores, communication tips, and ideal responses
- **Analytics Dashboard**: Track progress with charts, session history, and performance metrics
- **Authentication**: Sign in with Google or anonymously
- **Offline Support**: Local caching with Hive
- **Speech-to-Text**: Voice input for answers during interviews

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │    Supabase     │    │   Google AI     │
│                 │    │                 │    │   Gemini API    │
│ - Riverpod      │    │ - PostgreSQL    │    │                 │
│ - Material 3    │    │ - Auth          │    │ - Text Analysis │
│ - Async UI      │    │ - Storage       │    │ - Interview Gen │
│                 │    │ - RLS Policies  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   User Device   │
                    │                 │
                    │ - PDF Parsing   │
                    │ - Local Cache   │
                    │ - Speech Input  │
                    └─────────────────┘
```

## Folder Structure

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── providers/
│   ├── router/
│   ├── services/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   ├── presentation/
│   │   └── providers/
│   ├── resume/
│   │   ├── domain/
│   │   └── presentation/
│   ├── interview/
│   │   ├── domain/
│   │   └── presentation/
│   ├── analytics/
│   │   └── presentation/
│   ├── dashboard/
│   │   └── presentation/
│   └── settings/
│       └── presentation/
└── main.dart

supabase/
└── migrations/
    ├── 001_initial_schema.sql
    └── 002_rls_policies.sql
```

## Prerequisites

- Flutter 3.22+
- Dart 3.4+
- Supabase account (free)
- Google AI Studio account (free for Gemini API)

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/interview-iq-ai.git
   cd interview-iq-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Environment setup**
   - Copy `.env.example` to `.env`
   - Get Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey) (free)
   - Create a new Supabase project at [supabase.com](https://supabase.com) (free)

4. **Supabase configuration**
   - In Supabase dashboard, go to SQL Editor
   - Run the contents of `supabase/migrations/001_initial_schema.sql`
   - Run the contents of `supabase/migrations/002_rls_policies.sql`
   - Enable Google Auth:
     - Go to Authentication > Providers
     - Enable Google, add your OAuth client ID/secret

5. **Storage setup** (CRITICAL for resume uploads)
   - In Supabase dashboard, go to **Storage**
   - Click **Create bucket**
   - Name: `resumes`
   - Set as **Public** ✅
   - Or follow the detailed setup in `SUPABASE_STORAGE_SETUP.md`

6. **Run the app**
   ```bash
    flutter run
    ```

## Local Analysis Mode (No Cloud Storage Required)

The app now works completely **without Supabase storage setup**! It automatically uses **local analysis mode** with:

- ✅ AI-powered resume analysis (Groq API)
- ✅ Mock interview questions generation
- ✅ Real-time feedback evaluation
- ✅ Local caching to avoid repeated API calls
- ✅ Resume files saved locally on device
- ✅ Works offline after first analysis

**No Supabase bucket setup required** - just add your Groq API key and you're ready to go!

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| SUPABASE_URL | Your Supabase project URL | Yes |
| SUPABASE_ANON_KEY | Supabase anon/public key | Yes |
| GEMINI_API_KEY | Google Gemini API key | Yes |

## Deployment

### Web Deployment

1. Build for web:
   ```bash
   flutter build web --release
   ```

2. Deploy to Vercel:
   - Create a new project on [vercel.com](https://vercel.com)
   - Upload the `build/web` folder
   - Set environment variables in Vercel dashboard

### Mobile Deployment

- **Android**: `flutter build apk --release`
- **iOS**: `flutter build ios --release` (requires macOS)

## Interview Language Cheat Sheet

### STAR Method
- **Situation**: Set the context
- **Task**: Explain your responsibility
- **Action**: Describe what you did
- **Result**: Share the outcome with metrics

### Common Phrases
- "Based on my experience at X company..."
- "I led a team of Y people to achieve Z..."
- "The key challenge was..., and I solved it by..."
- "This resulted in A% improvement in B metric"

### Behavioral Questions
- Focus on impact and learnings
- Use specific examples with numbers
- Show leadership and collaboration

### Technical Questions
- Explain your thought process
- Consider edge cases
- Optimize for time/space complexity
- Ask clarifying questions

## Screenshots

### Home Dashboard
![Home Screen](screenshots/home.png)

### Resume Analysis
![Analysis Screen](screenshots/analysis.png)

### Mock Interview
![Interview Screen](screenshots/interview.png)

### Analytics Dashboard
![Analytics Screen](screenshots/analytics.png)

## License

MIT License - see [LICENSE](LICENSE) file for details.