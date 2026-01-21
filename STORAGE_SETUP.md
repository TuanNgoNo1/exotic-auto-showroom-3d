# Supabase Storage Setup Guide

This guide explains how to set up Storage buckets in Supabase for the Exotic Auto Showroom 3D app.

---

## 📦 Required Storage Buckets

You need to create **4 storage buckets** in Supabase:

### 1. **car-images** - Car exterior photos
### 2. **car-models** - 3D model files (GLB/GLTF)
### 3. **car-panoramas** - 360° panorama images
### 4. **car-interior-images** - Interior photo gallery
### 5. **avatars** - User profile pictures

---

## 🚀 Step-by-Step Setup

### Step 1: Go to Storage Section

1. Open your Supabase project dashboard
2. Click **"Storage"** in the left sidebar
3. Click **"Create a new bucket"**

---

### Step 2: Create Buckets

Create each bucket with these settings:

#### **Bucket 1: car-images**
- **Name:** `car-images`
- **Public bucket:** ✅ **YES** (checked)
- **File size limit:** 10 MB
- **Allowed MIME types:** `image/jpeg, image/png, image/webp`

#### **Bucket 2: car-models**
- **Name:** `car-models`
- **Public bucket:** ✅ **YES** (checked)
- **File size limit:** 50 MB
- **Allowed MIME types:** `model/gltf-binary, model/gltf+json, application/octet-stream`

#### **Bucket 3: car-panoramas**
- **Name:** `car-panoramas`
- **Public bucket:** ✅ **YES** (checked)
- **File size limit:** 20 MB
- **Allowed MIME types:** `image/jpeg, image/png`

#### **Bucket 4: car-interior-images**
- **Name:** `car-interior-images`
- **Public bucket:** ✅ **YES** (checked)
- **File size limit:** 10 MB
- **Allowed MIME types:** `image/jpeg, image/png, image/webp`

#### **Bucket 5: avatars**
- **Name:** `avatars`
- **Public bucket:** ✅ **YES** (checked)
- **File size limit:** 5 MB
- **Allowed MIME types:** `image/jpeg, image/png, image/webp`

---

### Step 3: Set Storage Policies (Optional but Recommended)

For each bucket, you can set RLS policies:

#### **For car-images, car-models, car-panoramas, car-interior-images:**

**Policy 1: Public Read Access**
```sql
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'car-images');
```

**Policy 2: Authenticated Upload (Admin only)**
```sql
CREATE POLICY "Authenticated users can upload"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'car-images' AND auth.role() = 'authenticated');
```

#### **For avatars:**

**Policy 1: Public Read Access**
```sql
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');
```

**Policy 2: Users can upload their own avatar**
```sql
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

**Policy 3: Users can update their own avatar**
```sql
CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

---

## 📂 Folder Structure (Recommended)

Organize your files in buckets like this:

```
car-images/
├── vinfast/
│   ├── vf9-exterior.jpg
│   └── vf8-exterior.jpg
├── mercedes/
│   └── s-class-exterior.jpg
└── porsche/
    └── 911-exterior.jpg

car-models/
├── vinfast/
│   ├── vf9-exterior.glb
│   └── vf9-interior.glb
└── mercedes/
    └── s-class-exterior.glb

car-panoramas/
├── vinfast/
│   └── vf9-interior-360.jpg
└── mercedes/
    └── s-class-interior-360.jpg

car-interior-images/
├── vinfast/
│   ├── vf9-dashboard.jpg
│   ├── vf9-seats.jpg
│   └── vf9-steering.jpg
└── mercedes/
    ├── s-class-dashboard.jpg
    └── s-class-seats.jpg

avatars/
├── {user-id-1}/
│   └── avatar.jpg
└── {user-id-2}/
    └── avatar.jpg
```

---

## 🔗 Getting File URLs

After uploading files, get the public URL:

### Method 1: From Supabase Dashboard
1. Go to Storage → Select bucket
2. Click on a file
3. Copy the **Public URL**

### Method 2: Programmatically (in Flutter)
```dart
final url = supabase.storage
    .from('car-images')
    .getPublicUrl('vinfast/vf9-exterior.jpg');
```

---

## 📝 Example URLs

After setup, your URLs will look like:

```
https://your-project.supabase.co/storage/v1/object/public/car-images/vinfast/vf9-exterior.jpg
https://your-project.supabase.co/storage/v1/object/public/car-models/vinfast/vf9-exterior.glb
https://your-project.supabase.co/storage/v1/object/public/car-panoramas/vinfast/vf9-interior-360.jpg
```

---

## ✅ Verification Checklist

After setup, verify:

- [ ] All 5 buckets created
- [ ] All buckets are **public**
- [ ] Can upload files to each bucket
- [ ] Can access files via public URL
- [ ] RLS policies are set (optional)

---

## 🎯 Next Steps

1. Upload your car images, 3D models, and panoramas
2. Copy the public URLs
3. Update the `cars` table with these URLs:
   - `image_url` → car-images bucket
   - `model_3d_exterior_url` → car-models bucket
   - `panorama_interior_url` → car-panoramas bucket
4. Update `car_interior_images` table with interior image URLs

---

## 🆘 Troubleshooting

**Problem:** Can't access files (403 Forbidden)
- **Solution:** Make sure bucket is set to **Public**

**Problem:** Upload fails
- **Solution:** Check file size limits and MIME types

**Problem:** RLS policy blocks access
- **Solution:** Review and update storage policies in SQL Editor

---

**Done! Your storage is ready for the app.** 🎉
