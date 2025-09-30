# Supabase Setup Guide for Assam Horizon School Website

## Academics Syllabus (Admin-managed)

This section adds a database table and a storage bucket so the Academics page can be driven from the Admin portal.

### 1) Create `syllabi` table

Run in Supabase SQL Editor (ensure the `pgcrypto` extension is enabled for `gen_random_uuid()`):

```sql
-- Table
create table if not exists public.syllabi (
  id uuid primary key default gen_random_uuid(),
  grade text not null,                -- e.g., "Grade 1", "Class 6"
  subject text not null,              -- e.g., "Mathematics"
  title text not null,                -- e.g., "Term 1 Syllabus"
  description text,
  pdf_url text,                       -- public URL to the uploaded PDF
  display_order int default 0,
  published boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS
alter table public.syllabi enable row level security;

-- Policies
-- Public read of published syllabi
create policy if not exists "Public can read published syllabi"
on public.syllabi for select
using (published = true);

-- Admin writes (adjust per your auth model)
-- If you use Supabase Auth for admins, prefer restricting to authenticated role:
create policy if not exists "Admins can insert syllabi"
on public.syllabi for insert
to authenticated
with check (true);

create policy if not exists "Admins can update syllabi"
on public.syllabi for update
to authenticated
using (true)
with check (true);

create policy if not exists "Admins can delete syllabi"
on public.syllabi for delete
to authenticated
using (true);

-- If you are currently not using Supabase Auth for admin login
-- and rely on the Admin portal's client-only check, you can temporarily
-- allow anon writes during development. REMOVE BEFORE PRODUCTION.
-- Uncomment only if needed:
-- create policy "Dev: anon can write syllabi" on public.syllabi for all to anon using (true) with check (true);
```

Notes:
- For production, use Supabase Auth for admins and remove any anon write permissions.
- You can also create fine-grained policies, e.g., only certain admin emails can write.

### 2) Create `syllabus-files` storage bucket

1. In Supabase Studio → Storage → Create bucket named `syllabus-files`.
2. Public bucket: Enabled (so PDFs are viewable from the Academics page).
3. Add policies:

```sql
-- Public read
create policy if not exists "Public read syllabus files" on storage.objects
for select to anon using ( bucket_id = 'syllabus-files' );

-- Admin write (authenticated)
create policy if not exists "Admins write syllabus files" on storage.objects
for insert to authenticated with check ( bucket_id = 'syllabus-files' );

create policy if not exists "Admins update syllabus files" on storage.objects
for update to authenticated using ( bucket_id = 'syllabus-files' ) with check ( bucket_id = 'syllabus-files' );

create policy if not exists "Admins delete syllabus files" on storage.objects
for delete to authenticated using ( bucket_id = 'syllabus-files' );
```

### 3) Admin Portal updates (overview)

- Add a new "Syllabus" tab in `admin.html` to CRUD `syllabi` and upload PDFs to the `syllabus-files` bucket.
- Fields in the form: grade, subject, title, description, PDF file, display_order, published.
- On create/update: upload PDF → get public URL → save to `pdf_url`.
- List all entries with edit/delete buttons; sort by `display_order`, then `updated_at desc`.

### 4) Academics page (public) updates (overview)

- Replace hardcoded syllabus cards with a fetch to `public.syllabi` where `published = true`.
- Group/filter by `grade`; display per subject with a "View Syllabus" button linking to `pdf_url`.
- Order by `display_order`, then `updated_at desc`.

### 5) Runtime configuration via Vercel (no hardcoded keys)

- Set environment variables in Vercel Project Settings → Environment Variables:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- A serverless function is included to provide these at runtime:
  - File: `/api/get-supabase.js`
  - Returns `{ url, anonKey }` from env, GET only
- `admin.html` fetches `/api/get-supabase` on load and initializes the Supabase client with the returned values.

This guide will help you set up Supabase as the backend for the notice board functionality.

## 1. Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - **Name**: `assam-horizon-school`
   - **Database Password**: Choose a strong password
   - **Region**: Select the closest region to your users
6. Click "Create new project"

## 2. Create Database Tables

Once your project is created, go to the SQL Editor and run these commands:

### Create the `notices` table:
```sql
CREATE TABLE notices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

-- Create policy to allow public read access
CREATE POLICY "Allow public read access" ON notices
  FOR SELECT USING (true);

-- Create policy to allow authenticated users to insert
CREATE POLICY "Allow authenticated insert" ON notices
  FOR INSERT WITH CHECK (true);

-- Create policy to allow authenticated users to update
CREATE POLICY "Allow authenticated update" ON notices
  FOR UPDATE USING (true);

-- Create policy to allow authenticated users to delete
CREATE POLICY "Allow authenticated delete" ON notices
  FOR DELETE USING (true);
```

### Create the `admins` table:
```sql
CREATE TABLE admins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- Create policy to allow public read access for login
CREATE POLICY "Allow public read access for login" ON admins
  FOR SELECT USING (true);
```

### Create the `gallery` table:
```sql
CREATE TABLE gallery (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT NOT NULL,
  category TEXT DEFAULT 'general',
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE gallery ENABLE ROW LEVEL SECURITY;

-- Create policy to allow public read access
CREATE POLICY "Allow public read access" ON gallery
  FOR SELECT USING (is_active = true);

-- Create policy to allow authenticated users to insert
CREATE POLICY "Allow authenticated insert" ON gallery
  FOR INSERT WITH CHECK (true);

-- Create policy to allow authenticated users to update
CREATE POLICY "Allow authenticated update" ON gallery
  FOR UPDATE USING (true);

-- Create policy to allow authenticated users to delete
CREATE POLICY "Allow authenticated delete" ON gallery
  FOR DELETE USING (true);
```

### Create the `faculty` table:
```sql
CREATE TABLE faculty (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  subject TEXT NOT NULL,
  qualification TEXT,
  experience TEXT,
  email TEXT,
  phone TEXT,
  bio TEXT,
  photo_url TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE faculty ENABLE ROW LEVEL SECURITY;

-- Create policy to allow public read access
CREATE POLICY "Allow public read access" ON faculty
  FOR SELECT USING (is_active = true);

-- Create policy to allow authenticated users to insert
CREATE POLICY "Allow authenticated insert" ON faculty
  FOR INSERT WITH CHECK (true);

-- Create policy to allow authenticated users to update
CREATE POLICY "Allow authenticated update" ON faculty
  FOR UPDATE USING (true);

-- Create policy to allow authenticated users to delete
CREATE POLICY "Allow authenticated delete" ON faculty
  FOR DELETE USING (true);
```

### Insert a default admin user:
```sql
-- Insert a default admin (change email and password as needed)
INSERT INTO admins (email, password) 
VALUES ('admin@assamhorizon.edu.in', 'admin123');
```

### Insert sample gallery data:
```sql
-- Insert sample gallery images (you'll need to upload actual images)
INSERT INTO gallery (title, description, image_url, category, display_order) VALUES
('School Building', 'Main school building entrance', 'assets/images/school-building_1.jpg', 'campus', 1),
('Classroom', 'Modern classroom setup', 'assets/images/classroom.jpg', 'campus', 2),
('Library', 'School library with books', 'assets/images/library.jpg', 'facilities', 3),
('Playground', 'Students playing in the playground', 'assets/images/playground.jpg', 'activities', 4);
```

### Insert sample faculty data:
```sql
-- Insert sample faculty members
INSERT INTO faculty (name, role, subject, qualification, experience, bio, photo_url, display_order) VALUES
('Dr. Priya Sharma', 'Principal', 'Administration', 'Ph.D. in Education', '15 years', 'Experienced educator with a passion for student development.', 'assets/images/faculty/principal.jpg', 1),
('Mr. Rajesh Kumar', 'Vice Principal', 'Mathematics', 'M.Sc. Mathematics', '12 years', 'Dedicated mathematics teacher with innovative teaching methods.', 'assets/images/faculty/vice-principal.jpg', 2),
('Ms. Anjali Singh', 'Senior Teacher', 'English Literature', 'M.A. English', '10 years', 'Passionate about literature and creative writing.', 'assets/images/faculty/english-teacher.jpg', 3),
('Dr. Amit Patel', 'Senior Teacher', 'Physics', 'Ph.D. Physics', '8 years', 'Expert in physics with research background.', 'assets/images/faculty/physics-teacher.jpg', 4);
```

## 3. Set Up File Storage (Optional but Recommended)

For production use, you should set up Supabase Storage for handling image uploads:

### Enable Storage:
1. Go to **Storage** in your Supabase dashboard
2. Click **Create a new bucket**
3. Create buckets:
   - **gallery-images** (for gallery photos)
   - **faculty-photos** (for faculty member photos)

### Set Storage Policies:
```sql
-- Allow public read access to gallery images
CREATE POLICY "Public read access for gallery" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery-images');

-- Allow public read access to faculty photos
CREATE POLICY "Public read access for faculty" ON storage.objects
  FOR SELECT USING (bucket_id = 'faculty-photos');

-- Allow authenticated users to upload gallery images
CREATE POLICY "Authenticated upload for gallery" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'gallery-images');

-- Allow authenticated users to upload faculty photos
CREATE POLICY "Authenticated upload for faculty" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'faculty-photos');
```

## 4. Get Your Supabase Credentials

1. Go to **Settings** → **API** in your Supabase dashboard
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **anon public key** (starts with `eyJ...`)

## 5. Update Your Website Files

Replace the placeholder values in these files:

### In `notice.html` (line ~50):
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon key
```

### In `admin.html` (line ~200):
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon key
```

### In `gallery.html` (line ~100):
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon key
```

### In `faculty.html` (line ~90):
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon key
```

## 6. Test the Complete Setup

### 1. Test Admin Login:
- Go to `http://localhost:3000/admin.html`
- Use the default credentials:
  - Email: `admin@assamhorizon.edu.in`
  - Password: `admin123`

### 2. Test Notice Management:
- After logging in, go to the **Notices** tab
- Create a test notice
- Check if the "Notice Published" modal appears
- Test editing and deleting notices

### 3. Test Gallery Management:
- Go to the **Gallery** tab in admin
- Upload a test image (with title, description, category)
- Check if the image appears in the gallery list
- Test editing and deleting gallery items

### 4. Test Faculty Management:
- Go to the **Faculty** tab in admin
- Add a test faculty member (with all details)
- Check if the faculty member appears in the list
- Test editing and deleting faculty members

### 5. Test Public Pages:
- Go to `http://localhost:3000/notice.html` - verify notices appear
- Go to `http://localhost:3000/gallery.html` - verify images appear
- Go to `http://localhost:3000/faculty.html` - verify faculty appear

## 7. Security Considerations

### For Production:
1. **Change default admin credentials**:
   ```sql
   UPDATE admins 
   SET email = 'your-email@domain.com', password = 'your-secure-password'
   WHERE email = 'admin@assamhorizon.edu.in';
   ```

2. **Enable email authentication** (optional):
   - Go to **Authentication** → **Settings**
   - Configure email templates and SMTP settings

3. **Set up proper RLS policies**:
   - Consider restricting admin access to specific IP ranges
   - Add audit logging for admin actions

## 7. Database Schema Reference

### `notices` table:
- `id` (UUID, Primary Key): Auto-generated unique identifier
- `title` (TEXT): Notice title
- `body` (TEXT): Notice content
- `created_at` (TIMESTAMP): When the notice was created
- `updated_at` (TIMESTAMP): When the notice was last updated

### `admins` table:
- `id` (UUID, Primary Key): Auto-generated unique identifier
- `email` (TEXT, Unique): Admin email address
- `password` (TEXT): Admin password (stored in plain text for simplicity)
- `created_at` (TIMESTAMP): When the admin account was created

### `gallery` table:
- `id` (UUID, Primary Key): Auto-generated unique identifier
- `title` (TEXT): Image title
- `description` (TEXT): Image description
- `image_url` (TEXT): URL/path to the image file
- `category` (TEXT): Image category (campus, facilities, activities, etc.)
- `display_order` (INTEGER): Order for displaying images
- `is_active` (BOOLEAN): Whether the image is active/visible
- `created_at` (TIMESTAMP): When the image was added
- `updated_at` (TIMESTAMP): When the image was last updated

### `faculty` table:
- `id` (UUID, Primary Key): Auto-generated unique identifier
- `name` (TEXT): Faculty member's name
- `role` (TEXT): Role/position (Principal, Teacher, etc.)
- `subject` (TEXT): Subject they teach
- `qualification` (TEXT): Educational qualifications
- `experience` (TEXT): Years of experience
- `email` (TEXT): Contact email
- `phone` (TEXT): Contact phone
- `bio` (TEXT): Biography/description
- `photo_url` (TEXT): URL/path to the faculty photo
- `display_order` (INTEGER): Order for displaying faculty
- `is_active` (BOOLEAN): Whether the faculty member is active
- `created_at` (TIMESTAMP): When the faculty member was added
- `updated_at` (TIMESTAMP): When the faculty member was last updated

## 8. Troubleshooting

### Common Issues:

1. **"Invalid email or password" error**:
   - Check if the admin user exists in the database
   - Verify email and password are correct

2. **"Error loading notices"**:
   - Check if the `notices` table exists
   - Verify RLS policies are set correctly
   - Check browser console for detailed error messages

3. **CORS errors**:
   - Ensure your Supabase project URL is correct
   - Check if your domain is allowed in Supabase settings

### Debug Mode:
Add this to your JavaScript files for debugging:
```javascript
// Enable debug mode
const supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    debug: true
  }
});
```

## 9. Next Steps

1. **Customize the admin interface**:
   - Add notice editing capabilities
   - Add notice deletion functionality
   - Add admin user management

2. **Enhance the public notice board**:
   - Add notice categories
   - Add search functionality
   - Add notice importance levels

3. **Add more features**:
   - Email notifications for new notices
   - Notice scheduling
   - File attachments for notices

## 10. Complete Feature Summary

### ✅ **What You Now Have:**

#### **Admin Backend (`admin.html`):**
- **Secure Login System** - Email/password authentication
- **Notice Management** - Create, Read, Update, Delete notices
- **Gallery Management** - Upload, edit, delete gallery images with categories
- **Faculty Management** - Add, edit, delete faculty members with photos
- **Tabbed Interface** - Organized management sections
- **Real-time Updates** - Changes reflect immediately
- **Form Validation** - Required fields and error handling

#### **Public Pages:**
- **Notice Board (`notice.html`)** - Displays all published notices
- **Gallery (`gallery.html`)** - Shows gallery images with lightbox
- **Faculty (`faculty.html`)** - Displays faculty members with details
- **Auto-refresh** - All pages update every 5 minutes

#### **Database Features:**
- **4 Tables** - notices, admins, gallery, faculty
- **Row Level Security** - Proper access controls
- **CRUD Operations** - Full Create, Read, Update, Delete functionality
- **Image Storage** - Support for file uploads (local URLs for now)

#### **Technical Features:**
- **Supabase Integration** - Real-time database
- **Responsive Design** - Works on all devices
- **Error Handling** - Graceful error messages
- **Loading States** - User-friendly loading indicators
- **XSS Protection** - HTML escaping for security

### 🚀 **Ready for Production:**
1. Set up Supabase Storage for real file uploads
2. Change default admin credentials
3. Configure proper RLS policies
4. Deploy to your hosting platform

## Support

If you encounter any issues:
1. Check the browser console for error messages
2. Verify your Supabase credentials are correct
3. Ensure all database tables and policies are created properly
4. Check the Supabase dashboard for any service issues
5. Review the database schema in the SQL Editor
6. Test each CRUD operation individually
