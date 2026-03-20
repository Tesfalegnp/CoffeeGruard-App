# ☕🌿 CoffeeGuard App

**CoffeeGuard** is an AI-powered Flutter mobile application designed to detect coffee leaf diseases using a two-stage machine learning model.
It works **offline-first**, stores results locally, and automatically syncs with Supabase when internet is available.

---

## 🚀 Features

* 📸 Capture or upload coffee leaf images
* 🤖 Two-stage AI model detection:

  * Level 1: Verify coffee leaf
  * Level 2: Detect disease (e.g., rust, healthy)
* 💾 Offline-first storage using Hive
* ☁️ Automatic sync with Supabase when internet is available
* 📊 Detection history (local + synced)
* 👨‍🌾 Farmer-friendly UI (no login required)
* 🔐 Ready for Expert & Admin roles (future)

---

## 🧠 How It Works

```
Image → Model 1 → (Is Coffee Leaf?)
          ↓
        YES → Model 2 → Disease Detection
          ↓
   Save Locally (Hive)
          ↓
   Internet Available?
        YES → Upload to Supabase
        NO  → Wait for Sync
```

---

## 🛠️ Tech Stack

* **Flutter (SDK >= 3.0.0)**
* **Dart**
* **TensorFlow Lite (tflite_flutter)**
* **Supabase (Backend & Storage)**
* **Hive (Offline Database)**
* **Provider (State Management)**

---

## 📂 Project Structure

```
lib/
├── config/          # App & Supabase config
├── core/
│   ├── services/    # Detection, Sync, Hive
│   ├── utils/       # Helpers
│   └── theme/       # UI theme
├── ml/              # ML model handlers
├── models/          # Data models
├── providers/       # State management
├── repositories/    # Data layer
├── screens/         # UI screens
├── widgets/         # Reusable components
└── main.dart
```

---

## 🔧 Requirements

### 1. Install Tools

| Tool               | Version                 |
| ------------------ | ----------------------- |
| Flutter            | 3.x.x (stable)          |
| Dart               | Included with Flutter   |
| Android Studio     | Latest                  |
| VS Code (optional) | Latest                  |
| Git                | Latest                  |
| Android SDK        | API 33+                 |
| NDK                | Installed automatically |

---

### 2. Enable Developer Mode (Windows)

Required for plugins:

```bash
start ms-settings:developers
```

Turn ON:

* Developer Mode

---

### 3. Clone the Repository

```bash
git clone https://github.com/Tesfalegnp/CoffeeGruard-App.git
cd CoffeeGruard-App
```

---

### 4. Install Dependencies

```bash
flutter pub get
```

---

### 5. Setup Environment Variables

Create `.env` file in root:

```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

⚠️ Do NOT commit this file.

---

### 6. Run the App (Debug)

```bash
flutter run
```

---

### 7. Build APK (Release)

```bash
flutter build apk --release
```

APK will be generated at:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

### 8. Install APK on Device

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

If already installed:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 📱 Expected App Flow

1. Open app → Hero Home Screen
2. Choose:

   * Capture Image
   * Upload from Gallery
3. AI processes image
4. Result displayed
5. Saved locally
6. If internet:

   * Auto upload to Supabase
7. View history anytime

---

## 📦 Assets Required

Make sure these exist:

```
assets/models/coffee_leaf_verification.tflite
assets/models/coffee_rust_model.tflite
assets/icons/app_icon.png
```

---

## ⚠️ Common Issues & Fixes

### ❌ Gradle / Build Errors

```bash
flutter clean
flutter pub get
```

---

### ❌ Device Not Detected

```bash
adb devices
```

Enable:

* USB Debugging
* Allow permissions on phone

---

### ❌ No Internet Sync

* Check Wi-Fi / Mobile Data
* Ensure Supabase is configured correctly

---

## 🔮 Future Improvements

* 👨‍🔬 Expert Dashboard
* 🛠 Admin Panel
* 📊 Analytics
* 🌍 Multi-language support
* 📡 Real-time sync monitoring

---

## 🤝 Contributing

1. Fork the repo
2. Create a new branch
3. Make changes
4. Submit pull request

---

## 📄 License

This project is for educational and research purposes.

---

## 👨‍💻 Author

Developed by **CoffeeGuard Team**

---

## ⭐ Support

If you like this project:

* ⭐ Star the repo
* 🍴 Fork it
* 📢 Share it

---

**Empowering farmers with AI 🌱**
