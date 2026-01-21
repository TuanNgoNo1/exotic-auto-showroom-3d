# Exotic Auto Showroom 3D 🚗

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase" alt="Supabase"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey" alt="Platform"/>
</p>

Cross-platform mobile application for exploring luxury cars with interactive 3D models, 360° panorama views, and real-time color customization.

---

## ✨ Features

- **Interactive 3D Car Viewer** - Rotate, zoom, and change car colors in real-time on GLB models
- **360° Interior Panorama** - Immersive car interior experience
- **Car Comparison** - Side-by-side comparison with visual charts and performance metrics
- **Personal Garage** - Save favorite car configurations with cloud sync
- **Search & Filter** - Find cars by brand, name, or specifications
- **Authentication** - Email/password login with profile management

---

## 🛠️ Tech Stack

**Frontend:**
- Flutter 3.10+ & Dart
- Riverpod (State Management)
- Model Viewer Plus (3D Rendering)
- Panorama Viewer (360° Views)
- Flutter Animate, Google Fonts, Cached Network Image

**Backend:**
- Supabase (PostgreSQL, Authentication, Storage, Row Level Security)
- RESTful API integration

**Architecture:**
- Clean Architecture (Presentation, State Management, Data layers)
- Repository Pattern
- 15+ Riverpod Providers

---

## 🚀 Setup & Run

### Prerequisites
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.10.0
- Android Studio / VS Code
- Supabase account (free tier available)

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/TuanNgoNo1/exotic-auto-showroom-3d.git
cd exotic-auto-showroom-3d
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Configure Supabase:**
   - Copy `.env.example` to `.env`
   - Add your Supabase credentials:
```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. **Run the app:**
```bash
# Debug mode
flutter run

# Release APK
flutter build apk --release
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # Entry point
├── core/                        # Theme, utils, exceptions
├── models/                      # Data models (Car, User)
├── providers/                   # Riverpod state management
│   ├── auth_provider.dart
│   ├── car_provider.dart
│   ├── garage_provider.dart
│   └── recently_viewed_provider.dart
├── screens/                     # UI screens (15+ screens)
│   ├── auth/                    # Login, Register
│   ├── home_screen.dart
│   ├── discovery_screen.dart
│   ├── car_detail_screen.dart
│   ├── compare_car_screen.dart
│   └── garage_screen.dart
├── services/                    # API & business logic
│   ├── car_service.dart
│   ├── garage_service.dart
│   └── storage_service.dart
└── widgets/                     # Reusable components
    ├── car_3d_viewer.dart
    ├── featured_car_card.dart
    └── glass_specs_panel.dart
```

---

## 🗄️ Database Schema

**8 Tables:**
- `brands` - Car manufacturers
- `cars` - Car details with 3D model URLs
- `car_specs` - Technical specifications
- `car_colors` - Available color options
- `car_interior_images` - Interior photo gallery
- `users` - User profiles
- `user_garage` - Saved car configurations

---

## 🎨 Design System

- **Dark Theme** with Gold accent (#FFD700)
- **Glassmorphism** effects
- **Smooth animations** with Flutter Animate
- **Responsive design** for multiple screen sizes

---

## 📱 Platforms

- ✅ Android
- ✅ iOS
- ✅ Web

---

## 📄 License

This project is developed for educational purposes.

---

## 👤 Author

**TuanNgoNo1**

Mobile Application Development Course | 2025-2026

---

<p align="center">Made with ❤️ and Flutter</p>
