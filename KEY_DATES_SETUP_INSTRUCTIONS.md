# Key Dates Feature - Setup Instructions

## Overview
You've successfully added a "Key Dates" management feature to your Admin portal! This allows you to set admission dates that automatically display on the Admissions page.

---

## Step 1: Create Supabase Table

**⚠️ IMPORTANT: Run this SQL first before testing!**

1. Go to your Supabase Dashboard: https://supabase.com/dashboard
2. Select your project: `mrthnvwokprolhaoimpg`
3. Click on **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy and paste the entire contents of `supabase_key_dates_schema.sql`
6. Click **Run** or press `Ctrl/Cmd + Enter`

✅ You should see: "Success. No rows returned"

---

## Step 2: Test the Admin Portal

1. **Open your local server**:
   - Make sure your server is running: `python3 -m http.server 8000`
   - Open: http://localhost:8000

2. **Login to Admin Portal**:
   - Go to: http://localhost:8000/admin.html
   - Login with your credentials

3. **Navigate to Key Dates Tab**:
   - Click on the **"Key Dates"** tab (purple icon with calendar)
   - You should see a form with date pickers

4. **Set Key Dates**:
   - **Applications Open**: Pick a date (e.g., October 1, 2026)
   - **Assessments Start**: Pick a date (e.g., October 15, 2026)
   - **Assessments End**: Pick a date (e.g., October 30, 2026)
   - **Decisions**: Pick a date (e.g., November 10, 2026)
   - Click **"Save Key Dates"**

5. **Verify Success**:
   - You should see a success modal: "Key Dates Saved!"
   - The "Current Key Dates" section below should update
   - You should see your dates nicely formatted

---

## Step 3: Test the Admissions Page

1. **Open Admissions Page**:
   - Go to: http://localhost:8000/admissions.html

2. **Check Key Dates Section**:
   - Look at the right sidebar: "Key Dates"
   - You should see your dates from the admin panel displayed here!
   - Format: "1 Oct", "15-30 Oct", "10 Nov"

3. **Test Real-time Updates**:
   - Go back to admin portal
   - Change one of the dates
   - Save
   - Refresh the admissions page
   - The dates should update immediately!

---

## Features

### Admin Portal (admin.html)
- ✅ New "Key Dates" tab with purple theme
- ✅ Date pickers for all fields
- ✅ Date range picker for Assessments (start to end)
- ✅ Validation: End date must be after start date
- ✅ Validation: Decisions must be after assessments
- ✅ Display current key dates with formatted dates
- ✅ Last updated timestamp

### Admissions Page (admissions.html)
- ✅ Dynamically loads key dates from Supabase
- ✅ Nicely formatted dates (e.g., "1 Oct", "15-30 Oct")
- ✅ Loading indicator while fetching
- ✅ Fallback to default dates if database is empty or error occurs
- ✅ Icons for each date type

---

## Database Schema

**Table: `key_dates`**

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `applications_open` | DATE | Date applications open |
| `assessments_start` | DATE | Assessment period start |
| `assessments_end` | DATE | Assessment period end |
| `decisions` | DATE | Decision notification date |
| `created_at` | TIMESTAMP | When record was created |
| `updated_at` | TIMESTAMP | When record was last updated |

**Note**: This table is designed to have only ONE active row (the current admission cycle). When you save, it updates the existing row rather than creating a new one.

---

## Troubleshooting

### Issue: "Error loading key dates" on admissions page
- **Solution**: Make sure you ran the SQL schema in Supabase
- Check Supabase dashboard → Table Editor → key_dates table exists

### Issue: "Failed to save key dates" in admin
- **Solution**: Check Row Level Security (RLS) policies
- The SQL schema includes public policies for testing
- For production, you may want to restrict who can modify dates

### Issue: Dates not updating on admissions page
- **Solution**: Hard refresh the page (Ctrl/Cmd + Shift + R)
- Check browser console for errors (F12 → Console tab)

### Issue: Validation errors when saving
- **Solution**: Make sure:
  - Assessments end date is AFTER start date
  - Decisions date is AFTER assessments end date

---

## Next Steps (Optional Enhancements)

1. **Add Academic Year Field**: Track multiple admission cycles
2. **Add Email Notifications**: Auto-send emails when dates change
3. **Add Calendar Integration**: Export to Google Calendar/iCal
4. **Add Countdown Timers**: Show "X days until applications open"
5. **Add Past Cycles Archive**: View historical admission dates

---

## Files Modified

1. `admin.html` - Added Key Dates tab and management functions
2. `admissions.html` - Added dynamic key dates loading
3. `supabase_key_dates_schema.sql` - Database schema (NEW)
4. `KEY_DATES_SETUP_INSTRUCTIONS.md` - This file (NEW)

---

## Support

If you encounter any issues:
1. Check browser console (F12)
2. Check Supabase logs
3. Verify SQL was run successfully
4. Ensure Supabase client is initialized

Happy managing! 🎓📅

