# La Casserole - Quick Start Guide

**Repository**: https://github.com/JeromeDuboisPro/la-casserole.git
**Project Directory**: `/home/jerome/devs/JDPRO/casserole`

---

## 1. Initialize Git Repository

```bash
cd /home/jerome/devs/JDPRO/casserole

# Initialize git if not already done
git init

# Add remote
git remote add origin https://github.com/JeromeDuboisPro/la-casserole.git

# Create initial commit with documentation
git add claudedocs/
git commit -m "📚 Initial documentation: PRD, architecture, and quick start

✨ Project: La Casserole - French protest casserole app
📱 Platform: Flutter (Android → iOS)
💰 Model: Ad-supported + donations
🎯 MVP: 3-4 weeks

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to main
git branch -M main
git push -u origin main
```

---

## 2. Flutter Environment Setup

### Check Flutter Installation
```bash
# Verify Flutter is installed
flutter doctor -v

# If not installed, run:
# wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
# tar xf flutter_linux_3.16.0-stable.tar.xz
# export PATH="$PATH:$HOME/flutter/bin"
# Add to ~/.bashrc for persistence
```

### Accept Android Licenses
```bash
flutter doctor --android-licenses
```

### Expected Output
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.0)
[✓] Android toolchain - develop for Android devices
[✓] Chrome - develop for the web
[✓] Android Studio
[✓] Connected device (1 available) <- Your Android phone
```

---

## 3. Create Flutter Project

```bash
cd /home/jerome/devs/JDPRO/casserole

# Create Flutter project with org identifier
flutter create . --org com.lacasserole --project-name casserole

# This will generate:
# - lib/ (Dart code)
# - android/ (Android-specific)
# - ios/ (iOS-specific, for Phase 2)
# - test/ (Unit/widget tests)
# - pubspec.yaml (dependencies)
```

---

## 4. Configure Dependencies

### Edit `pubspec.yaml`

```yaml
name: casserole
description: La Casserole - Protest solidarity app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1

  # Audio
  audioplayers: ^5.2.1

  # Haptics
  vibration: ^1.8.4

  # Images
  image_picker: ^1.0.5
  image_cropper: ^5.0.1

  # Storage
  shared_preferences: ^2.2.2

  # Backend
  firebase_core: ^2.24.2
  firebase_database: ^10.4.0
  firebase_analytics: ^10.7.4

  # Monetization
  google_mobile_ads: ^4.0.0
  in_app_purchase: ^3.1.11

  # Utilities
  url_launcher: ^6.2.2
  package_info_plus: ^5.0.1
  intl: ^0.18.1  # For number formatting

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

flutter:
  uses-material-design: true

  assets:
    - assets/audio/
    - assets/images/
    - assets/images/flags/
    - assets/images/symbols/
```

### Install Dependencies
```bash
flutter pub get
```

---

## 5. Create Project Structure

```bash
# Create directory structure
mkdir -p lib/{core/{constants,theme,utils},data/{models,repositories,services},presentation/{screens,widgets,providers},config}
mkdir -p assets/{audio,images/{flags,symbols}}
mkdir -p test/{unit,widget}
```

---

## 6. Connect Your Android Phone

### Enable Developer Mode
1. **Settings** → **About Phone** → Tap **Build Number** 7 times
2. **Settings** → **Developer Options** → Enable **USB Debugging**
3. Connect phone via USB

### Verify Connection
```bash
flutter devices

# Expected output:
# Android SDK built for x86 • emulator-5554 • android-x86 • Android 11 (API 30) (emulator)
# Pixel 6 • <device-id> • android-arm64 • Android 13 (API 33) (your phone)
```

---

## 7. Test Basic Flutter Setup

### Create Simple Hello World

```bash
# Replace lib/main.dart with a test
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Casserole',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: Scaffold(
        appBar: AppBar(title: Text('La Casserole - Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🥘', style: TextStyle(fontSize: 100)),
              SizedBox(height: 20),
              Text('La Casserole', style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text('Flutter setup successful!'),
            ],
          ),
        ),
      ),
    );
  }
}
EOF
```

### Run on Your Phone
```bash
# Hot reload enabled (instant updates during development)
flutter run

# Select your Android device when prompted
# App should launch on your phone showing casserole emoji
```

---

## 8. Firebase Setup (Backend for Global Counter)

### Create Firebase Project
1. Go to https://console.firebase.google.com/
2. **Add Project** → Name: "La Casserole"
3. **Disable Google Analytics** (optional for MVP)
4. **Create Project**

### Add Android App
1. **Project Settings** → **Add App** → **Android**
2. **Android Package Name**: `com.lacasserole.casserole`
3. **Download `google-services.json`**
4. **Place file**: `android/app/google-services.json`

### Configure Android Build
Add to `android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // Add this
    }
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'  // Add at bottom
```

### Enable Realtime Database
1. Firebase Console → **Realtime Database** → **Create Database**
2. **Start in test mode** (we'll secure later)
3. Database URL: `https://la-casserole-xxxxx.firebaseio.com/`

### Initialize in Flutter
```bash
# Generate Firebase configuration
flutterfire configure --project=la-casserole
```

---

## 9. AdMob Setup (Monetization)

### Create AdMob Account
1. Go to https://apps.admob.com/
2. **Sign up** with Google account
3. **Add App** → Select **Android**
4. **App Name**: La Casserole
5. **Copy Ad Unit IDs**:
   - Banner: `ca-app-pub-xxxxx/banner-id`
   - Interstitial: `ca-app-pub-xxxxx/interstitial-id`

### Configure Android Manifest
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest>
    <application>
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-xxxxx~app-id"/>
    </application>
</manifest>
```

---

## 10. Prepare Assets

### Audio Files (Metallic Bangs)
Download free metallic impact sounds from:
- **Freesound.org**: Search "metal pot bang"
- **ZapSplat.com**: Free sound effects

Place 5 variations in `assets/audio/`:
- `bang_01.mp3`
- `bang_02.mp3`
- `bang_03.mp3`
- `bang_04.mp3`
- `bang_05.mp3`

### Casserole Image
- Find or create casserole PNG (2048x2048)
- Save as `assets/images/casserole.png`
- Compress with TinyPNG to <500KB

### Flag Icons
Download 256x256 flag PNGs:
- France: `assets/images/flags/france.png`
- Rainbow: `assets/images/flags/rainbow.png`
- Black: `assets/images/flags/black.png`
- Red: `assets/images/flags/red.png`
- (Add 6-10 more based on PRD)

---

## 11. Development Workflow

### Branch Strategy
```bash
# Create feature branch for each milestone
git checkout -b feature/core-mechanics
# Work on core casserole interaction

git checkout -b feature/customization
# Work on flag/image pickers

git checkout -b feature/monetization
# Work on ads and IAP
```

### Commit Pattern
```bash
# Commit frequently with descriptive messages
git add .
git commit -m "✨ feat: Add casserole spin animation with haptic feedback

- Implemented AnimationController for 360° rotation
- Integrated vibration package for medium impact
- Added tap gesture detection

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"

git push origin feature/core-mechanics
```

### Hot Reload During Development
```bash
# Run app
flutter run

# Make code changes → Press 'r' in terminal for hot reload
# Press 'R' for hot restart (full reload)
# Press 'q' to quit
```

---

## 12. Testing on Your Android Phone

### Physical Device Testing
```bash
# List connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build release APK for manual testing
flutter build apk --release

# Install APK on phone
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Debug Tips
```bash
# View logs
flutter logs

# Check for performance issues
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
```

---

## 13. Ready to Start Development!

### Week 1 Checklist
- [ ] Flutter environment verified (`flutter doctor`)
- [ ] Project created and dependencies installed
- [ ] Git repository initialized and pushed
- [ ] Android phone connected and test app runs
- [ ] Firebase project created and configured
- [ ] AdMob account created (can use test IDs initially)
- [ ] Audio assets prepared and placed in `assets/audio/`
- [ ] Casserole image prepared and placed in `assets/images/`

### Next Steps
1. **Read PRD** (`claudedocs/PRD_La_Casserole.md`)
2. **Review Architecture** (`claudedocs/TECH_ARCHITECTURE.md`)
3. **Start Week 1**: Implement core casserole mechanics
   - Casserole widget with tap detection
   - Spin animation
   - Audio system
   - Haptic feedback
   - Spark particle effect

### Resources
- **Flutter Docs**: https://docs.flutter.dev/
- **Provider Pattern**: https://pub.dev/packages/provider
- **Firebase Setup**: https://firebase.google.com/docs/flutter/setup
- **AdMob Integration**: https://developers.google.com/admob/flutter/quick-start

---

## 14. Troubleshooting

### Flutter Doctor Issues
```bash
# Android license issues
flutter doctor --android-licenses

# SDK path not found
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Device Not Detected
```bash
# Check USB debugging
adb devices

# Restart ADB server
adb kill-server
adb start-server
```

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

---

**Ready to bang for change! 🥘✊**
