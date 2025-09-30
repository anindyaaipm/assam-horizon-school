# Production Deployment Guide - Assam Horizon School Website

This guide will help you deploy your school website to production with proper security measures.

## 🚀 Deployment Options

### Option 1: Static Hosting (Recommended for this project)
- **Netlify** (Free tier available)
- **Vercel** (Free tier available)
- **GitHub Pages** (Free)
- **Firebase Hosting** (Free tier available)

### Option 2: Traditional Web Hosting
- **Shared Hosting** (cPanel, etc.)
- **VPS/Cloud Servers** (DigitalOcean, AWS, etc.)

## 📋 Pre-Deployment Checklist

### 1. Security Configuration

#### A. Update Supabase Security Settings
```sql
-- 1. Change default admin credentials
UPDATE admins 
SET email = 'your-secure-email@yourdomain.com', 
    password = 'your-very-secure-password-123!'
WHERE email = 'admin@assamhorizon.edu.in';

-- 2. Add additional admin users if needed
INSERT INTO admins (email, password) 
VALUES ('admin2@yourdomain.com', 'another-secure-password-456!');
```

#### B. Configure Supabase RLS Policies (Production)
```sql
-- Restrict admin access to specific IP ranges (optional)
CREATE POLICY "Restrict admin access by IP" ON admins
  FOR ALL USING (
    current_setting('request.headers')::json->>'x-forwarded-for' 
    IN ('YOUR_OFFICE_IP', 'YOUR_HOME_IP')
  );

-- Add audit logging for admin actions
CREATE TABLE admin_audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  admin_email TEXT NOT NULL,
  action TEXT NOT NULL,
  table_name TEXT NOT NULL,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### C. Set Up Supabase Storage (Production)
1. **Create Storage Buckets:**
   - Go to Supabase Dashboard → Storage
   - Create bucket: `gallery-images`
   - Create bucket: `faculty-photos`

2. **Configure Storage Policies:**
```sql
-- Public read access for images
CREATE POLICY "Public read access for gallery" ON storage.objects
  FOR SELECT USING (bucket_id = 'gallery-images');

CREATE POLICY "Public read access for faculty" ON storage.objects
  FOR SELECT USING (bucket_id = 'faculty-photos');

-- Authenticated upload only
CREATE POLICY "Authenticated upload for gallery" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'gallery-images' AND 
    auth.role() = 'authenticated'
  );

CREATE POLICY "Authenticated upload for faculty" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'faculty-photos' AND 
    auth.role() = 'authenticated'
  );
```

### 2. Update Website Configuration

#### A. Replace Placeholder Credentials
Update these files with your actual Supabase credentials:

**In all HTML files, replace:**
```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

**With your actual values:**
```javascript
const SUPABASE_URL = 'https://your-project-id.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

#### B. Update Image Upload Functionality
Replace the placeholder image upload code in `admin.html` with real Supabase Storage:

```javascript
// Replace the image upload section in admin.html
async function uploadImage(file, bucket) {
  const fileExt = file.name.split('.').pop();
  const fileName = `${Date.now()}.${fileExt}`;
  
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(fileName, file);
    
  if (error) throw error;
  
  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(fileName);
    
  return publicUrl;
}
```

### 3. Domain and SSL Configuration

#### A. Custom Domain Setup
1. **Purchase a domain** (e.g., `assamhorizon.edu.in`)
2. **Configure DNS** to point to your hosting provider
3. **Enable SSL certificate** (most hosting providers offer free SSL)

#### B. Update Contact Information
Update all contact details in your website:
- School address
- Phone numbers
- Email addresses
- Social media links

## 🌐 Deployment Steps

### Method 1: Netlify Deployment (Recommended)

#### Step 1: Prepare Your Files
```bash
# Create a production-ready folder
mkdir assam-horizon-production
cp -r /Users/asarkar2025/Documents/assam-horizon-school/* assam-horizon-production/

# Remove development files
rm assam-horizon-production/SUPABASE_SETUP.md
rm assam-horizon-production/PRODUCTION_DEPLOYMENT.md
```

#### Step 2: Deploy to Netlify
1. **Go to [netlify.com](https://netlify.com)**
2. **Sign up/Login** with your GitHub account
3. **Click "New site from Git"**
4. **Connect your repository** or drag & drop your folder
5. **Configure build settings:**
   - Build command: (leave empty for static sites)
   - Publish directory: `/` (root directory)
6. **Deploy!**

#### Step 3: Configure Custom Domain
1. **In Netlify dashboard** → Site settings → Domain management
2. **Add custom domain** → `assamhorizon.edu.in`
3. **Configure DNS** at your domain registrar:
   ```
   Type: CNAME
   Name: www
   Value: your-site-name.netlify.app
   
   Type: A
   Name: @
   Value: 75.2.60.5
   ```

### Method 2: Vercel Deployment

#### Step 1: Install Vercel CLI
```bash
npm install -g vercel
```

#### Step 2: Deploy
```bash
cd /Users/asarkar2025/Documents/assam-horizon-school
vercel --prod
```

#### Step 3: Configure Domain
1. **In Vercel dashboard** → Project → Settings → Domains
2. **Add your domain** → `assamhorizon.edu.in`
3. **Update DNS** at your domain registrar

### Method 3: Traditional Web Hosting

#### Step 1: Prepare Files
```bash
# Create a zip file of your website
cd /Users/asarkar2025/Documents/assam-horizon-school
zip -r assam-horizon-website.zip . -x "*.md" "*.DS_Store"
```

#### Step 2: Upload to Hosting
1. **Login to your hosting control panel** (cPanel, etc.)
2. **Go to File Manager**
3. **Navigate to public_html** (or your domain's root folder)
4. **Upload and extract** your zip file
5. **Set proper file permissions:**
   - Folders: 755
   - Files: 644

## 🔒 Security Measures

### 1. Supabase Security

#### A. Environment Variables (Production)
Create a `.env` file (don't commit to version control):
```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

#### B. API Rate Limiting
```sql
-- Enable rate limiting in Supabase
-- Go to Dashboard → Settings → API → Rate Limiting
-- Set appropriate limits for your use case
```

#### C. Database Backups
1. **Enable automatic backups** in Supabase Dashboard
2. **Set up regular exports** of your data
3. **Test restore procedures** periodically

### 2. Website Security

#### A. Content Security Policy (CSP)
Add to your HTML files:
```html
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://unpkg.com; 
               style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; 
               img-src 'self' data: https:; 
               connect-src 'self' https://*.supabase.co;">
```

#### B. HTTPS Enforcement
```html
<!-- Add to all HTML files -->
<meta http-equiv="Strict-Transport-Security" 
      content="max-age=31536000; includeSubDomains">
```

#### C. Input Validation
Ensure all forms have proper validation:
```javascript
// Example: Enhanced form validation
function validateForm(formData) {
  const errors = [];
  
  // Email validation
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
    errors.push('Invalid email format');
  }
  
  // Phone validation
  if (formData.phone && !/^[\+]?[0-9\s\-\(\)]{10,}$/.test(formData.phone)) {
    errors.push('Invalid phone number');
  }
  
  // File size validation
  if (formData.file && formData.file.size > 5 * 1024 * 1024) {
    errors.push('File size must be less than 5MB');
  }
  
  return errors;
}
```

### 3. Monitoring and Maintenance

#### A. Error Monitoring
```javascript
// Add error tracking to your JavaScript
window.addEventListener('error', function(e) {
  // Log errors to your monitoring service
  console.error('JavaScript Error:', e.error);
  
  // Send to monitoring service (e.g., Sentry, LogRocket)
  if (typeof Sentry !== 'undefined') {
    Sentry.captureException(e.error);
  }
});
```

#### B. Performance Monitoring
```html
<!-- Add Google Analytics or similar -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

#### C. Regular Maintenance Tasks
1. **Weekly:**
   - Check website functionality
   - Review admin login logs
   - Monitor error rates

2. **Monthly:**
   - Update dependencies
   - Review security logs
   - Backup database
   - Test restore procedures

3. **Quarterly:**
   - Security audit
   - Performance review
   - Update SSL certificates
   - Review and update admin passwords

## 📊 Post-Deployment Testing

### 1. Functional Testing
- [ ] Admin login works
- [ ] All CRUD operations function
- [ ] Public pages load correctly
- [ ] Images display properly
- [ ] Forms submit successfully
- [ ] Mobile responsiveness works

### 2. Security Testing
- [ ] HTTPS is enforced
- [ ] Admin panel is protected
- [ ] Input validation works
- [ ] File upload restrictions work
- [ ] XSS protection is active

### 3. Performance Testing
- [ ] Page load times are acceptable
- [ ] Images are optimized
- [ ] Database queries are efficient
- [ ] CDN is working (if applicable)

## 🚨 Emergency Procedures

### 1. Website Down
1. **Check hosting status** (Netlify, Vercel, etc.)
2. **Check domain DNS** settings
3. **Check Supabase status** (status.supabase.com)
4. **Restore from backup** if necessary

### 2. Security Breach
1. **Change all admin passwords** immediately
2. **Review access logs** in Supabase
3. **Check for unauthorized changes**
4. **Update security policies**
5. **Notify stakeholders**

### 3. Data Loss
1. **Check Supabase backups**
2. **Restore from most recent backup**
3. **Verify data integrity**
4. **Update backup procedures**

## 📞 Support Contacts

### Technical Support
- **Supabase Support:** [supabase.com/support](https://supabase.com/support)
- **Hosting Support:** Contact your hosting provider
- **Domain Support:** Contact your domain registrar

### Emergency Contacts
- **School IT Administrator:** [Your contact info]
- **Web Developer:** [Your contact info]
- **Hosting Provider:** [Support contact]

## 📝 Maintenance Schedule

### Daily
- [ ] Check website accessibility
- [ ] Monitor error logs

### Weekly
- [ ] Review admin activity
- [ ] Check for updates
- [ ] Test critical functions

### Monthly
- [ ] Security review
- [ ] Performance analysis
- [ ] Backup verification
- [ ] Content updates

### Quarterly
- [ ] Full security audit
- [ ] Dependency updates
- [ ] SSL certificate renewal
- [ ] Disaster recovery testing

---

## 🎉 Congratulations!

Your Assam Horizon School website is now ready for production with enterprise-level security measures. The website provides:

- ✅ **Secure admin management** system
- ✅ **Real-time content updates**
- ✅ **Professional public interface**
- ✅ **Mobile-responsive design**
- ✅ **Comprehensive security measures**
- ✅ **Scalable architecture**

Your school now has a modern, secure, and maintainable web presence that will serve your community effectively! 🏫✨
