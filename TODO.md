- [ ] Remove Supabase completely (dependencies, init in main.dart, providers/services/auth, analytics/history persistence)
- [ ] Update Riverpod interview flow: generate questions, store answers, evaluate once on Finish/Submit, navigate to final results
- [ ] Implement local (Hive) interview session persistence for offline results
- [ ] Harden Groq JSON parsing + models (safe parsing for lists/dynamic/null, recommended_improvements mapping)
- [ ] Update InterviewResultScreen UI: show all AI fields with “Actionable Recommendations” for recommended_improvements
- [ ] Remove any remaining Supabase-related imports/dead code; ensure app builds
- [ ] Improve Groq service JSON-only, retry, and Dio error handling if needed
- [ ] Run flutter analyze + flutter test/build to confirm stability

