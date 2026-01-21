-- =====================================================
-- EXOTIC AUTO SHOWROOM 3D - SUPABASE DATABASE SETUP
-- =====================================================
-- Run this script in Supabase SQL Editor to create all tables
-- Go to: https://supabase.com/dashboard → Your Project → SQL Editor → New Query

-- =====================================================
-- 1. BRANDS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS brands (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    logo_url TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. CARS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id UUID REFERENCES brands(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    price DECIMAL(12, 2) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    
    -- 3D Models
    model_3d_exterior_url TEXT,
    model_3d_interior_url TEXT,
    model_file_size_mb DECIMAL(5, 2),
    model_optimized BOOLEAN DEFAULT FALSE,
    body_material_name VARCHAR(100),
    
    -- Panorama
    panorama_interior_url TEXT,
    
    -- Metadata
    year INTEGER,
    is_featured BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. CAR SPECS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS car_specs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
    spec_key VARCHAR(100) NOT NULL,
    spec_value TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(car_id, spec_key)
);

-- =====================================================
-- 4. CAR COLORS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS car_colors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
    color_name VARCHAR(100) NOT NULL,
    color_hex VARCHAR(7) NOT NULL,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 5. CAR INTERIOR IMAGES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS car_interior_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. USERS TABLE (extends auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL UNIQUE,
    full_name VARCHAR(200),
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. USER GARAGE TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS user_garage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
    selected_color_id UUID REFERENCES car_colors(id) ON DELETE SET NULL,
    custom_name VARCHAR(200),
    notes TEXT,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, car_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_cars_brand_id ON cars(brand_id);
CREATE INDEX IF NOT EXISTS idx_cars_is_featured ON cars(is_featured);
CREATE INDEX IF NOT EXISTS idx_cars_is_available ON cars(is_available);
CREATE INDEX IF NOT EXISTS idx_car_specs_car_id ON car_specs(car_id);
CREATE INDEX IF NOT EXISTS idx_car_colors_car_id ON car_colors(car_id);
CREATE INDEX IF NOT EXISTS idx_car_interior_images_car_id ON car_interior_images(car_id);
CREATE INDEX IF NOT EXISTS idx_user_garage_user_id ON user_garage(user_id);
CREATE INDEX IF NOT EXISTS idx_user_garage_car_id ON user_garage(car_id);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE car_specs ENABLE ROW LEVEL SECURITY;
ALTER TABLE car_colors ENABLE ROW LEVEL SECURITY;
ALTER TABLE car_interior_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_garage ENABLE ROW LEVEL SECURITY;

-- Public read access for brands, cars, specs, colors, interior images
CREATE POLICY "Public read access for brands" ON brands FOR SELECT USING (true);
CREATE POLICY "Public read access for cars" ON cars FOR SELECT USING (true);
CREATE POLICY "Public read access for car_specs" ON car_specs FOR SELECT USING (true);
CREATE POLICY "Public read access for car_colors" ON car_colors FOR SELECT USING (true);
CREATE POLICY "Public read access for car_interior_images" ON car_interior_images FOR SELECT USING (true);

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can manage their own garage
CREATE POLICY "Users can read own garage" ON user_garage FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert to own garage" ON user_garage FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own garage" ON user_garage FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete from own garage" ON user_garage FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- SAMPLE DATA (Optional - for testing)
-- =====================================================

-- Insert sample brand
INSERT INTO brands (name, description) VALUES 
('VinFast', 'Vietnamese automotive manufacturer'),
('Mercedes-Benz', 'German luxury automobile manufacturer'),
('Porsche', 'German sports car manufacturer')
ON CONFLICT (name) DO NOTHING;

-- Insert sample car (VinFast VF 9)
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
    b.id,
    'VinFast VF 9',
    83000,
    'Premium electric SUV with advanced technology and spacious interior',
    'https://example.com/vinfast-vf9.jpg',
    2024,
    true,
    true
FROM brands b WHERE b.name = 'VinFast'
ON CONFLICT DO NOTHING;

-- Note: Add more sample data as needed for your app

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for cars table
DROP TRIGGER IF EXISTS update_cars_updated_at ON cars;
CREATE TRIGGER update_cars_updated_at
    BEFORE UPDATE ON cars
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for users table
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
-- Next steps:
-- 1. Go to Storage section and create buckets (see STORAGE_SETUP.md)
-- 2. Upload your car images, 3D models, and panorama images
-- 3. Update the URLs in the cars table
-- 4. Enable Email authentication in Authentication settings
