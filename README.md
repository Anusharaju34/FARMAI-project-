# 🌾 FARMAI – Smart Farming Assistant

<p align="center">
  <img src="assets/images/logo.png" width="120" alt="FARMAI Logo"/>
</p>

<p align="center">
  <strong>AI-powered Flutter application for smart, data-driven agriculture</strong><br/>
  Final Year Project · Flutter 3.x · Supabase · Riverpod · Go Router
</p>

---

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Tech Stack](#tech-stack)
4. [Project Structure](#project-structure)
5. [Getting Started](#getting-started)
6. [Supabase Setup](#supabase-setup)
7. [Environment Variables](#environment-variables)
8. [Running the App](#running-the-app)
9. [Building for Release](#building-for-release)
10. [Deployment Guide](#deployment-guide)
11. [API Integrations](#api-integrations)
12. [Screen Walkthrough](#screen-walkthrough)

---

## 🌱 Project Overview

FARMAI is a production-ready Flutter mobile application that empowers farmers with AI-driven tools for crop disease diagnosis, pest identification, smart irrigation planning, real-time weather monitoring, and crop market intelligence. It also features a farmer community forum and a direct expert helpline.

---

## ✨ Features

| Module | Features |
|--------|----------|
| 🔐 Authentication | Register, Login, Forgot Password, Email Verification |
| 🏠 Dashboard | Weather card, crop alerts, market snapshot, quick actions |
| 🔬 Disease Detection | Camera/gallery upload → AI diagnosis → treatment plan |
| 🐛 Pest Detection | Pest identification → severity rating → control measures |
| 🌦️ Weather | Real-time weather, 5-day forecast, farming advisory |
| 📈 Market Prices | Live prices, 14-day prediction, trend chart, AI advisory |
| 💧 Irrigation | Crop+soil input → water requirement → weekly schedule |
| 💬 Community Forum | Post discussions, like, comment, search, hashtags |
| 👨‍🔬 Expert Helpline | Submit questions → expert replies → ticket tracking |
| 🔔 Notifications | Real-time push via Supabase Realtime, read/unread state |
| 👤 Profile | Edit profile, photo upload, diagnosis history |
| ⚙️ Settings | Notification toggles, dark mode, language, location |

---

## 🛠 Tech Stack

```
Flutter 3.x          – Cross-platform mobile framework
Dart                 – Programming language
Supabase             – Backend (Auth, PostgreSQL, Storage, Realtime)
Riverpod 2.x         – State management
Go Router 13.x       – Declarative navigation
Material 3           – UI design system
Google Fonts         – Plus Jakarta Sans typography
FL Chart             – Market price charts
Flutter Animate      – Micro-animations
Image Picker         – Camera & gallery access
Dio                  – HTTP client (WeatherAPI)
```

---

## 📁 Project Structure

```
farmai/
├── .env.example                    # Environment template
├── .env                            # Your local environment (git-ignored)
├── .gitignore
├── pubspec.yaml
├── supabase_schema.sql             # Complete database schema + RLS + seed
├── supabase_storage.sql            # Storage buckets + policies
├── supabase/
│   └── functions/
│       ├── notify-farmer/          # Edge Function: push notifications
│       └── update-market-prices/   # Edge Function: daily price update cron
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml     # Camera, storage, location permissions
├── assets/
│   ├── images/
│   │   └── logo.png               # FARMAI brand logo
│   └── icons/
└── lib/
    ├── main.dart                   # App entry point
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart  # Supabase table names, crop lists, sizing
    │   └── theme/
    │       └── app_theme.dart      # Material 3 light + dark themes
    ├── models/
    │   └── models.dart             # All data models (User, Disease, Pest, …)
    ├── services/
    │   ├── supabase_service.dart   # All Supabase CRUD operations
    │   └── weather_service.dart    # WeatherAPI integration
    ├── providers/
    │   └── providers.dart          # Riverpod state providers + notifiers
    ├── routes/
    │   └── app_router.dart         # Go Router config + auth redirect guard
    ├── screens/
    │   ├── auth/                   # Splash, Onboarding, Login, Register, ForgotPassword
    │   ├── home/                   # Dashboard
    │   ├── disease/                # Disease Detection
    │   ├── pest/                   # Pest Detection
    │   ├── weather/                # Weather & Forecast
    │   ├── market/                 # Market Price Prediction
    │   ├── irrigation/             # Smart Irrigation Advisor
    │   ├── forum/                  # Community Forum
    │   ├── expert/                 # Expert Helpline
    │   ├── notifications/          # Notification Center
    │   ├── profile/                # User Profile
    │   └── settings/               # App Settings
    └── widgets/
        └── common/
            ├── common_widgets.dart  # FarmTextField, LoadingButton, StatusBadge, …
            └── main_scaffold.dart   # Bottom nav shell
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `≥ 3.0.0` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Dart SDK `≥ 3.0.0` (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- A [Supabase](https://supabase.com) account (free tier works)
- A [WeatherAPI](https://www.weatherapi.com) key (free tier: 1M calls/month)

### 1. Clone / Unzip

```bash
# If cloning from GitHub
git clone https://github.com/your-username/farmai.git
cd farmai

# Or unzip the downloaded file
unzip farmai.zip
cd farmai
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

---

## 🗄️ Supabase Setup

### Step 1 — Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) → **New Project**
2. Choose your organisation, enter project name `farmai`, set a strong database password
3. Select a region closest to your users (e.g. Singapore for India)
4. Wait ~2 minutes for provisioning

### Step 2 — Run the Database Schema

1. In your Supabase dashboard → **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase_schema.sql`
3. Click **Run** — this creates all 10 tables, indexes, RLS policies, triggers, and seed data

### Step 3 — Run the Storage Setup

1. In **SQL Editor** → **New Query**
2. Paste the entire contents of `supabase_storage.sql`
3. Click **Run** — this creates `crop-images`, `pest-images`, `profile-images` buckets with access policies

### Step 4 — Configure Auth

1. Supabase Dashboard → **Authentication** → **Providers** → ensure **Email** is enabled
2. (Optional) Configure email templates under **Authentication** → **Email Templates**
3. For production, set your app's domain under **Authentication** → **URL Configuration**

### Step 5 — Get Your API Keys

1. Supabase Dashboard → **Project Settings** → **API**
2. Copy:
   - **Project URL** (e.g. `https://abcdefgh.supabase.co`)
   - **anon/public key** (safe to use in mobile apps)

### Step 6 — Deploy Edge Functions (Optional)

```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
supabase login
supabase link --project-ref your-project-ref

# Deploy functions
supabase functions deploy notify-farmer
supabase functions deploy update-market-prices

# Schedule daily market price update (Supabase Dashboard → Edge Functions → Schedules)
# Cron: "30 0 * * *"  (runs at 06:00 AM IST every day)
```

---

## 🔑 Environment Variables

```bash
# 1. Copy the template
cp .env.example .env

# 2. Edit .env with your actual values
```

**.env file:**
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...your-anon-key
WEATHER_API_KEY=your-weatherapi-key
```

> ⚠️ **Never commit `.env` to Git.** It is already listed in `.gitignore`.

---

## ▶️ Running the App

```bash
# Check connected devices
flutter devices

# Run in debug mode (hot reload enabled)
flutter run

# Run on specific device
flutter run -d emulator-5554      # Android emulator
flutter run -d iPhone             # iOS simulator

# Run with verbose logging
flutter run --verbose
```

---

## 📦 Building for Release

### Android APK

```bash
# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS + Xcode)

```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode and archive
```

### Signing for Android

1. Generate a keystore:
```bash
keytool -genkey -v -keystore android/key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias farmai
```

2. Create `android/key.properties`:
```
storePassword=your-store-password
keyPassword=your-key-password
keyAlias=farmai
storeFile=../key.jks
```

3. Update `android/app/build.gradle` to reference the keystore.

---

## 🌐 API Integrations

### WeatherAPI
- Endpoint: `https://api.weatherapi.com/v1/forecast.json`
- Free tier: 1,000,000 calls/month
- Used for: current weather, 7-day forecast, UV index, rainfall
- Sign up: [weatherapi.com](https://www.weatherapi.com)

### AI Disease / Pest Detection
The current implementation uses mock responses. To integrate a real ML model:

**Option A — Google Cloud Vision / AutoML**
```dart
// In disease_detection_screen.dart, replace the mock block with:
final response = await Dio().post(
  'https://automl.googleapis.com/v1/projects/{project}/locations/{location}/models/{model}:predict',
  data: {'payload': {'image': {'imageBytes': base64Image}}},
  options: Options(headers: {'Authorization': 'Bearer $token'}),
);
```

**Option B — Custom Python FastAPI + TensorFlow**
```python
# Deploy a FastAPI server with your trained model
@app.post("/predict")
async def predict(file: UploadFile):
    img = preprocess(await file.read())
    prediction = model.predict(img)
    return {"disease": classes[prediction.argmax()], "confidence": float(prediction.max())}
```

**Option C — Teachable Machine / Roboflow**
- Train on [Teachable Machine](https://teachablemachine.withgoogle.com)
- Export as TensorFlow Lite and use `tflite_flutter` package

---

## 📱 Screen Walkthrough

| # | Screen | Route |
|---|--------|-------|
| 1 | Splash Screen | `/` |
| 2 | Onboarding | `/onboarding` |
| 3 | Login | `/login` |
| 4 | Register | `/register` |
| 5 | Forgot Password | `/forgot-password` |
| 6 | Home Dashboard | `/home` |
| 7 | Disease Detection | `/disease-detection` |
| 8 | Pest Detection | `/pest-detection` |
| 9 | Weather | `/weather` |
| 10 | Market Prices | `/market-price` |
| 11 | Irrigation Advisor | `/irrigation` |
| 12 | Community Forum | `/community-forum` |
| 13 | Expert Helpline | `/expert-helpline` |
| 14 | Notifications | `/notifications` |
| 15 | Profile | `/profile` |
| 16 | Settings | `/settings` |

---

## 🗃️ Database Tables

| Table | Purpose |
|-------|---------|
| `users` | Farmer profiles |
| `disease_predictions` | AI disease detection history |
| `pest_detections` | Pest identification records |
| `weather_alerts` | Location-based weather alerts |
| `market_predictions` | Crop price data + forecasts |
| `irrigation_records` | Irrigation calculation history |
| `forum_posts` | Community discussion threads |
| `forum_comments` | Replies to forum posts |
| `forum_post_likes` | Like tracking (unique per user/post) |
| `expert_queries` | Farmer → expert Q&A tickets |
| `notifications` | In-app notification feed |

---

## 🔒 Security

- All tables use **Row Level Security (RLS)** — users can only access their own data
- Storage buckets enforce **folder-based ownership** — files only accessible by uploader
- `.env` with API keys is **git-ignored**
- Supabase **anon key** is safe for client use (RLS enforces data access)
- Auth tokens are managed by `supabase_flutter` SDK with automatic refresh

---

## 🤝 Contributing

1. Fork the repo
2. Create feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -m 'Add my feature'`
4. Push to branch: `git push origin feature/my-feature`
5. Open a Pull Request

---

## 📄 License

MIT License — free to use for academic and personal projects.

---

<p align="center">Made with ❤️ for farmers · FARMAI © 2025</p>
