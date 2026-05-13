# Supabase Storage Setup for InterviewIQ AI

## 🚨 IMPORTANT: Resume Upload Requires Storage Bucket Setup

If you're getting storage bucket errors when uploading resumes, follow these steps to set up Supabase Storage properly.

## Step-by-Step Setup

### 1. Create the Storage Bucket

1. Go to your [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Storage** in the left sidebar
4. Click **Create bucket**
5. Enter bucket name: `resumes`
6. Set as **Public** (important!)
7. Click **Create bucket**

### 2. Configure Bucket Policies

1. In the Storage section, click on the `resumes` bucket
2. Go to **Policies** tab
3. Click **Add Policy**
4. Select **Allow all users** for now (you can restrict later)
5. Or create a custom policy:

```sql
-- Allow authenticated users to upload their own files
CREATE POLICY "Users can upload their own resumes" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'resumes'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to view their own files
CREATE POLICY "Users can view their own resumes" ON storage.objects
FOR SELECT USING (
  bucket_id = 'resumes'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### 3. Verify Setup

1. Try uploading a resume in the app
2. Check browser console for any remaining errors
3. Files should appear in your Supabase Storage dashboard

## Troubleshooting

### Common Errors:

1. **"Bucket does not exist"**
   - Make sure you created the `resumes` bucket exactly as named

2. **"Permission denied"**
   - Ensure the bucket is set to **Public**
   - Check that your RLS policies allow uploads

3. **"Upload failed"**
   - Verify your Supabase URL and anon key in `.env` are correct

### Test Upload

You can temporarily use the fallback mode (when storage fails, it still analyzes the resume locally) to test the AI functionality while setting up storage.

## Alternative: Use Supabase CLI

If you prefer command line:

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Create bucket
supabase storage create resumes --public
```

## Need Help?

- Check the [Supabase Storage Docs](https://supabase.com/docs/guides/storage)
- Verify your project settings in the Supabase dashboard
- Ensure your `.env` file has the correct credentials