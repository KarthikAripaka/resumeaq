-- resumes table
CREATE TABLE resumes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_url TEXT NOT NULL,
  job_role TEXT NOT NULL,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_resumes_user_id ON resumes(user_id);

-- analyses table
CREATE TABLE analyses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  resume_id UUID NOT NULL REFERENCES resumes(id) ON DELETE CASCADE,
  ats_score INTEGER CHECK (ats_score BETWEEN 0 AND 100),
  strengths JSONB NOT NULL DEFAULT '[]',
  weaknesses JSONB NOT NULL DEFAULT '[]',
  missing_skills JSONB NOT NULL DEFAULT '[]',
  keyword_match JSONB NOT NULL DEFAULT '[]',
  improvement_tips JSONB NOT NULL DEFAULT '[]',
  summary TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_analyses_resume_id ON analyses(resume_id);

-- interview_sessions table
CREATE TABLE interview_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  resume_id UUID REFERENCES resumes(id),
  job_role TEXT NOT NULL,
  overall_score FLOAT,
  hr_score FLOAT,
  technical_score FLOAT,
  dsa_score FLOAT,
  project_score FLOAT,
  questions_total INTEGER DEFAULT 0,
  questions_answered INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_sessions_user_id ON interview_sessions(user_id);

-- question_responses table
CREATE TABLE question_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES interview_sessions(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  category TEXT NOT NULL,
  user_answer TEXT,
  ai_score INTEGER CHECK (ai_score BETWEEN 0 AND 10),
  ai_feedback JSONB,
  answered_at TIMESTAMPTZ DEFAULT NOW()
);

-- user_stats VIEW (not table — computed)
CREATE VIEW user_stats AS
SELECT
  user_id,
  COUNT(*) AS total_sessions,
  ROUND(AVG(overall_score), 1) AS avg_overall_score,
  MAX(overall_score) AS best_score,
  ROUND(AVG(
    (SELECT AVG(ats_score) FROM analyses a JOIN resumes r ON a.resume_id = r.id WHERE r.user_id = interview_sessions.user_id)
  ), 0) AS avg_ats_score
FROM interview_sessions
GROUP BY user_id;