-- Enable RLS on all tables
ALTER TABLE resumes ENABLE ROW LEVEL SECURITY;
ALTER TABLE analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE interview_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_responses ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data
CREATE POLICY "Users own resumes" ON resumes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users own sessions" ON interview_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users own responses via session" ON question_responses FOR ALL
  USING (session_id IN (SELECT id FROM interview_sessions WHERE user_id = auth.uid()));
CREATE POLICY "Users own analyses via resume" ON analyses FOR ALL
  USING (resume_id IN (SELECT id FROM resumes WHERE user_id = auth.uid()));

-- Storage bucket policy
-- Run this in Supabase dashboard Storage settings:
-- Bucket name: resumes, Public: false
-- Policy: authenticated users can upload/read their own folder: {user_id}/*