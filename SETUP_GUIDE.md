# Complete Setup Guide for Exotic Auto Showroom 3D

This guide will help you set up the entire project from scratch, including Supabase backend configuration.

---

## 📋 Prerequisites

Before starting, make sure you have:

- ✅ Flutter SDK >= 3.10.0 installed
- ✅ Dart SDK >= 3.10.0 installed
- ✅ Android Studio or VS Code
- ✅ Git installed
- ✅ A Supabase account (free tier is fine)

---

## 🚀 Quick Start (5 Steps)

### Step 1: Clone the Repository

```bash
git clone https://github.com/TuanNgoNo1/exotic-auto-showroom-3d.git
cd exotic-auto-showroom-3d
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Set Up Supabase Backend

#### 3.1. Create a Supabase Project

1. Go to https://supabase.com/dashboard
2. Click **"New Project"**
3. Fill in:
   - **Name:** `exotic-auto-showroom`
   - **Database Password:** (create a strong password)
   - **Region:** Choose closest to you
4. Click **"Create new project"** (wait 2-3 minutes)

#### 3.2. Get API Credentials

1. In your project dashboard, go to **Settings** → **API**
2. Copy these values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (long string starting with `eyJ...`)

#### 3.3. Configure Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   # Windows
   copy .env.example .env
   
   # Mac/Linux
   cp .env.example .env
   ```

2. Open `.env` and paste your credentials:
   ```env
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

#### 3.4. Create Database Tables

1. In Supabase dashboard, go to **SQL Editor**
2. Click **"New Query"**
3. Copy the entire content of `supabase_setup.sql` file
4. Paste into the SQL Editor
5. Click **"Run"** (bottom right)
6. Wait for success message ✅

#### 3.5. Set Up Storage Buckets

Follow the detailed guide in `STORAGE_SETUP.md`:

1. Go to **Storage** section in Supabase
2. Create 5 buckets:
   - `car-images` (public)
   - `car-models` (public)
   - `car-panoramas` (public)
   - `car-interior-images` (public)
   - `avatars` (public)

#### 3.6. Enable Email Authentication

1. Go to **Authentication** → **Providers**
2. Make sure **Email** is enabled ✅
3. (Optional) Configure email templates

### Step 4: Run the App

```bash
# Run in debug mode
flutter run

# Or build release APK
flutter build apk --release
```

### Step 5: Test the App

1. **Register a new account** (email + password)
2. **Browse cars** in Discovery tab
3. **View 3D models** (if you uploaded models)
4. **Add cars to garage**
5. **Compare cars**

---

## 📊 Adding Sample Data

To populate your database with sample cars:

### Option 1: Manual Entry (Recommended for learning)

1. Go to Supabase dashboard → **Table Editor**
2. Add data to tables in this order:
   - `brands` → Add car brands (VinFast, Mercedes, Porsche, etc.)
   - `cars` → Add car details with image URLs
   - `car_specs` → Add specifications (horsepower, torque, etc.)
   - `car_colors` → Add available colors
   - `car_interior_images` → Add interior photo URLs

### Option 2: SQL Insert Script

Create a file `sample_data.sql` and run in SQL Editor:

```sql
-- Insert brands
INSERT INTO brands (name, description) VALUES 
('VinFast', 'Vietnamese automotive manufacturer'),
('Mercedes-Benz', 'German luxury automobile manufacturer'),
('Porsche', 'German sports car manufacturer'),
('BMW', 'German luxury vehicle manufacturer'),
('Audi', 'German automotive manufacturer')
ON CONFLICT (name) DO NOTHING;

-- Insert a sample car (VinFast VF 9)
WITH brand AS (SELECT id FROM brands WHERE name = 'VinFast' LIMIT 1)
INSERT INTO cars (
    brand_id, 
    name, 
    price, 
    description, 
    image_url,
    year,
    is_featured,
    is_available
) 
SELECT 
    brand.id,
    'VinFast VF 9',
    83000,
    'Premium electric SUV with advanced technology and spacious interior. Features cutting-edge design and impressive performance.',
    'https://your-supabase-url.supabase.co/storage/v1/object/public/car-images/vinfast/vf9.jpg',
    2024,
    true,
    true
FROM brand
RETURNING id;

-- Add specs for VF 9 (replace {car_id} with actual ID from above)
INSERT INTO car_specs (car_id, spec_key, spec_value, display_order) VALUES
('{car_id}', 'Horsepower', '402 hp', 1),
('{car_id}', 'Torque', '640 Nm', 2),
('{car_id}', '0-100 km/h', '6.5 seconds', 3),
('{car_id}', 'Top Speed', '200 km/h', 4),
('{car_id}', 'Battery', '123 kWh', 5),
('{car_id}', 'Range', '680 km', 6),
('{car_id}', 'Seats', '7', 7),
('{car_id}', 'Drive Type', 'AWD', 8);

-- Add colors for VF 9
INSERT INTO car_colors (car_id, color_name, color_hex) VALUES
('{car_id}', 'Pearl White', '#FFFFFF'),
('{car_id}', 'Midnight Black', '#000000'),
('{car_id}', 'Ocean Blue', '#0066CC'),
('{car_id}', 'Ruby Red', '#CC0000'),
('{car_id}', 'Silver Metallic', '#C0C0C0');
```

---

## 🎨 Uploading Assets

### Car Images
1. Go to **Storage** → **car-images**
2. Create folder: `vinfast/`
3. Upload car exterior photos (JPG/PNG, max 10MB)
4. Copy public URL and paste into `cars.image_url`

### 3D Models (Optional)
1. Go to **Storage** → **car-models**
2. Upload GLB files (max 50MB)
3. Copy URL and paste into `cars.model_3d_exterior_url`

### Panorama Images (Optional)
1. Go to **Storage** → **car-panoramas**
2. Upload 360° panorama images
3. Copy URL and paste into `cars.panorama_interior_url`

---

## 🔧 Troubleshooting

### Problem: "Failed to load cars"
**Solution:**
- Check internet connection
- Verify `.env` file has correct Supabase credentials
- Make sure database tables are created
- Check Supabase project is not paused (free tier pauses after 7 days inactivity)

### Problem: "Authentication failed"
**Solution:**
- Go to Supabase → Authentication → Providers
- Make sure Email provider is enabled
- Check email confirmation settings

### Problem: "Images not loading"
**Solution:**
- Verify storage buckets are set to **Public**
- Check image URLs are correct
- Make sure files are uploaded to correct buckets

### Problem: "3D models not showing"
**Solution:**
- Verify GLB file format is correct
- Check file size (should be < 50MB)
- Make sure `model_3d_exterior_url` is set in database
- Test URL in browser first

---

## 📱 Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS (requires Mac)
```bash
flutter build ios --release
```

---

## 🎯 Next Steps

After setup is complete:

1. ✅ Add more cars to your database
2. ✅ Upload high-quality car images
3. ✅ (Optional) Add 3D models and panoramas
4. ✅ Customize the app theme in `lib/core/theme/app_theme.dart`
5. ✅ Test all features thoroughly
6. ✅ Build release APK for distribution

---

## 📚 Additional Resources

- **Flutter Documentation:** https://docs.flutter.dev
- **Supabase Documentation:** https://supabase.com/docs
- **Riverpod Documentation:** https://riverpod.dev
- **Model Viewer Plus:** https://pub.dev/packages/model_viewer_plus

---

## 🆘 Need Help?

If you encounter issues:

1. Check the troubleshooting section above
2. Review Supabase logs: Dashboard → Logs
3. Check Flutter logs: `flutter logs`
4. Open an issue on GitHub

---

**Happy coding! 🚀**
