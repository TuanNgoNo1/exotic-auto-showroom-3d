# App Icons & Splash Screen Assets

## Cần tạo các file sau:

### 1. app_icon.png
- Kích thước: 1024x1024 pixels
- Format: PNG
- Dùng cho: App icon trên cả Android và iOS

### 2. app_icon_foreground.png
- Kích thước: 1024x1024 pixels
- Format: PNG với transparent background
- Dùng cho: Android Adaptive Icon (foreground layer)
- Lưu ý: Icon nên nằm trong safe zone (66% center)

### 3. splash_logo.png
- Kích thước: 512x512 pixels
- Format: PNG với transparent background
- Dùng cho: Splash screen logo

## Công cụ tạo icon:
- https://www.appicon.co/ - Tạo icon từ 1 ảnh
- https://romannurik.github.io/AndroidAssetStudio/ - Android Asset Studio
- Figma/Sketch - Thiết kế custom

## Sau khi thêm icons, chạy:

```bash
# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screen
dart run flutter_native_splash:create
```

## Gợi ý thiết kế:
- Background color: #0D0D0D (dark)
- Accent color: #FFD700 (gold)
- Style: Minimalist, car silhouette hoặc steering wheel
