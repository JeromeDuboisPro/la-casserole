# 🥘 La Casserole

**Transform your phone into a digital protest instrument**

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green)](https://github.com/JeromeDuboisPro/la-casserole)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

La Casserole brings the iconic French protest tradition of banging pots and pans to your mobile device. Join millions worldwide in digital solidarity with protest movements.

---

## ✨ Features

🥘 **Interactive Casserole**
- Realistic spin animation with physics
- Multiple authentic metallic bang sounds
- Haptic feedback for immersive experience
- Visual spark effects on tap

🎨 **Customization**
- 10+ flags from worldwide movements
- Custom center images (personal photos or protest symbols)
- Persistent settings across sessions

🌍 **Global Solidarity**
- Real-time worldwide bang counter
- Milestone celebrations
- Track collective action impact

💰 **Support Causes**
- 50% of donations to activist organizations
- Transparent donation tracking
- Optional ad removal

---

## 🎯 Project Status

**Phase**: Requirements & Planning Complete ✅
**Next**: Flutter Environment Setup & Implementation
**Target**: Android MVP in 3-4 weeks

---

## 📚 Documentation

Complete project documentation is available in the `claudedocs/` directory:

- **[PRD (Product Requirements Document)](claudedocs/PRD_La_Casserole.md)**: Comprehensive product specification with features, monetization, and roadmap
- **[Technical Architecture](claudedocs/TECH_ARCHITECTURE.md)**: Flutter implementation details, services, and backend design
- **[Quick Start Guide](claudedocs/QUICK_START.md)**: Step-by-step setup instructions for development environment

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.16+ installed
- Android Studio or VSCode with Flutter extensions
- Android device with USB debugging enabled
- Git configured

### Setup
```bash
# Clone repository
git clone https://github.com/JeromeDuboisPro/la-casserole.git
cd la-casserole

# Create Flutter project
flutter create . --org com.lacasserole --project-name casserole

# Install dependencies
flutter pub get

# Connect your Android phone and run
flutter run
```

See **[Quick Start Guide](claudedocs/QUICK_START.md)** for detailed setup instructions.

---

## 🛠️ Technology Stack

**Framework**: Flutter 3.16+
**Language**: Dart 3.2+
**State Management**: Provider
**Backend**: Firebase Realtime Database
**Monetization**: Google AdMob + In-App Purchases
**Payment Processing**: Stripe (donations)

### Key Dependencies
- `audioplayers` - Low-latency audio playback
- `vibration` - Haptic feedback
- `image_picker` / `image_cropper` - User image customization
- `firebase_database` - Global counter sync
- `google_mobile_ads` - Ad integration
- `in_app_purchase` - Ad removal IAP

---

## 📱 Supported Platforms

| Platform | Status | Version |
|----------|--------|---------|
| Android  | ✅ In Development | MVP (3-4 weeks) |
| iOS      | 🔄 Planned | Phase 2 (2-3 weeks after Android) |
| Web      | 💡 Future | Phase 3 (optional) |

---

## 🗓️ Development Roadmap

### Phase 1: Android MVP (3-4 weeks)
- ✅ Requirements & planning complete
- ⏳ Week 1: Core mechanics (spin, audio, haptics, sparks)
- ⏳ Week 2: Customization (flags, images, backend)
- ⏳ Week 3: Monetization (ads, IAP, donations)
- ⏳ Week 4: Testing, polish, Google Play release

### Phase 2: iOS + Enhancements (2-3 weeks)
- iOS port and App Store submission
- Additional casserole designs and sounds
- Enhanced social sharing features

### Phase 3: Web Version (optional)
- Browser-based version for desktop
- PWA support for offline use

---

## 💡 Cultural Context

The casserole (pot) has been a powerful symbol of protest since the 18th century:

- **France**: Used during demonstrations to amplify voices
- **Quebec**: "Casserole nights" during student protests
- **Latin America**: "Cacerolazo" tradition
- **Modern Movements**: Yellow Vests, climate strikes

La Casserole digitizes this tradition, allowing global participation in solidarity actions from anywhere.

---

## 🤝 Contributing

This is currently a solo project in active development. Contributions will be welcome after the MVP release.

For bugs or suggestions, please open an issue on GitHub.

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- **Audio**: Metallic impact sounds from Freesound.org contributors
- **Icons**: Material Design and FontAwesome (open-source)
- **Inspiration**: Generations of protesters worldwide who've made their voices heard

---

## 📞 Contact

**Developer**: Jerome Dubois
**GitHub**: [@JeromeDuboisPro](https://github.com/JeromeDuboisPro)
**Repository**: https://github.com/JeromeDuboisPro/la-casserole

---

## 🎯 Project Metrics (Target)

| Metric | Target (3 months) |
|--------|-------------------|
| Downloads | 10,000+ |
| Global Bangs | 1,000,000+ |
| Daily Active Users | 20% of monthly |
| Revenue | €300-800/month |

---

**Bang for change. Bang for solidarity. 🥘✊**
