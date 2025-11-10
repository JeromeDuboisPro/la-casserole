# Product Requirements Document: La Casserole

**Version**: 1.0
**Date**: 2025-11-10
**Project Type**: Mobile Application (Android → iOS)
**Target Market**: French-speaking users, protest culture enthusiasts

---

## 1. Executive Summary

**La Casserole** is a mobile app simulating the iconic French protest tradition of banging pots and pans during demonstrations. Users tap the screen to spin a casserole with realistic sound effects, haptic feedback, and visual sparks. The app features a global participation counter, customizable flags and center images, fostering solidarity with worldwide protest movements.

**Core Value Proposition**: Transform your phone into a digital protest instrument, connect with global movements, and express solidarity through a culturally authentic, engaging experience.

---

## 2. Business Model

### Monetization Strategy: Hybrid (Ad-Supported + Solidarity Donations)

**Primary Revenue**: Ad-supported with optional ad removal
- Banner ads (non-intrusive placement)
- Interstitial ads (post-session, max 1 per 5 minutes of use)
- Rewarded video ads (optional, for bonus features)
- Ad removal IAP: €1.99

**Secondary Revenue**: Donation/Solidarity Model
- Optional tip jar with preset amounts (€1, €3, €5, custom)
- "Support a Cause" feature: 50% of donations go to user-selected activist organizations
- Transparency dashboard showing donation distribution
- Tax receipt generation for eligible donations

**Rationale**:
- Low development effort (B model advantage)
- Brand authenticity through cause alignment (C model advantage)
- Multiple revenue streams without complex freemium gating

---

## 3. Core Features (MVP - Android Launch)

### 3.1 Primary Interaction

**Casserole Display**
- High-quality 3D or stylized 2D casserole centered on screen
- Realistic metallic texture and lighting
- Default French casserole design (steel pot with handles)

**Tap Interaction**
- Single tap triggers continuous spin animation
- Spin duration: 1.5-2 seconds with deceleration physics
- Multiple rapid taps queue spins (max 3 queued)

**Audio System**
- 5-7 unique metallic bang sound variations
- Random selection on each tap for natural variation
- High-quality audio samples (44.1kHz, optimized for mobile)
- Volume respects system settings

**Visual Feedback**
- Spark particle effects emanating from tap point
- Spark color: Orange/yellow gradient with fade
- Duration: 0.3-0.5 seconds
- Intensity: 8-12 particles per tap

**Haptic Feedback**
- Medium impact haptic on tap (Android VibrationEffect.EFFECT_CLICK)
- Synchronizes with audio bang for tactile immersion

### 3.2 Customization Features

**Flag Selection**
- 10-15 flags representing major protest movements/nations
  - France (tricolor)
  - Rainbow (LGBTQ+ pride)
  - Black flag (anarchist/antifa)
  - Red flag (labor/socialist movements)
  - Palestinian flag
  - Ukrainian flag
  - Environmental movement flag
  - Regional flags (Catalonia, Brittany, etc.)
- Flag appears as small overlay in corner or border decoration
- One-tap selection from flag picker menu

**Center Image Customization**
- Circular image at casserole center
- Options:
  1. User photo from gallery (cropped to circle)
  2. Camera capture
  3. 5-10 predefined protest symbols (fist, megaphone, etc.)
- Image persists across sessions
- Clear/reset to default option

### 3.3 Social & Engagement

**Global Bang Counter**
- Persistent display showing total worldwide taps
- Real-time updates (backend aggregation every 5-10 seconds)
- Counter persists on screen with elegant design
- Milestone celebrations (confetti animation at 1M, 10M, 100M, etc.)

**Simple Sharing** (optional for MVP)
- "Share Your Bangs" button
- Generates shareable message: "I've banged [X] times for protest solidarity! 🥘 #LaCasserole"
- Direct share to social media (Android intent system)

---

## 4. User Experience Flow

### First Launch
1. Splash screen: "La Casserole" logo with subtle spin animation
2. Brief onboarding (2 screens):
   - Screen 1: "Tap to bang, join the global protest chorus"
   - Screen 2: "Customize your casserole, support causes you believe in"
3. Main screen with default casserole + global counter

### Main Screen Layout
```
┌─────────────────────────────┐
│  🇫🇷  [Flag]    [Settings]  │  <- Top bar
│                              │
│    [Global Counter]          │  <- Subtle fixed position
│       1,234,567              │
│                              │
│                              │
│      ╱───────╲              │
│     │  [IMG]  │             │  <- Casserole (tappable)
│      ╲───────╱              │
│                              │
│                              │
│  [💰 Support]  [Share]      │  <- Bottom actions
└─────────────────────────────┘
```

### Settings Screen
- Flag picker (grid of flag icons)
- Center image picker (gallery/camera/presets)
- Donation settings
- Ad removal purchase
- About/Credits
- Privacy policy

---

## 5. Technical Architecture

### Recommended Stack: **Flutter**

**Rationale**:
- Single codebase for Android → iOS → Web (future)
- Excellent animation/physics engine (Flutter's rendering)
- Strong community for protest/activism apps
- Your C++/Python background translates well to Dart
- Hot reload for rapid iteration
- Native performance for haptics and audio

**Alternative**: React Native
- Larger ecosystem, but heavier for animations
- Flutter preferred for this graphics/interaction-heavy app

### Core Technology Stack

**Framework**: Flutter 3.16+
**Language**: Dart
**State Management**: Provider or Riverpod (lightweight for MVP)
**Animations**: Flutter AnimationController + Physics simulations
**Audio**: audioplayers package (flutter_sound alternative)
**Haptics**: vibration package
**Image Handling**: image_picker + image_cropper
**Storage**: shared_preferences (local settings)
**Backend**: Firebase or Supabase (global counter + analytics)
**Ads**: Google AdMob (flutter_admob or google_mobile_ads)
**IAP**: in_app_purchase package

### Architecture Pattern: Clean Architecture (Simplified)

```
lib/
├── main.dart
├── core/
│   ├── constants.dart
│   ├── theme.dart
│   └── utils/
├── data/
│   ├── repositories/
│   └── models/
├── presentation/
│   ├── screens/
│   │   ├── main_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── casserole_widget.dart
│   │   ├── flag_picker.dart
│   │   └── global_counter.dart
│   └── providers/
└── services/
    ├── audio_service.dart
    ├── haptic_service.dart
    ├── counter_service.dart
    └── ad_service.dart
```

---

## 6. Backend Requirements (Minimal)

### Firebase Realtime Database or Firestore
- Global counter aggregation
- Schema:
  ```json
  {
    "global_counter": 1234567,
    "last_updated": "2025-11-10T14:30:00Z"
  }
  ```

### Increment Logic
- Client-side optimistic increment (immediate UI update)
- Batch writes to backend (every 5-10 taps or 10 seconds)
- Backend aggregates all client submissions

### Alternative: Simple REST API
- Single endpoint: `POST /api/bang` (increments counter)
- `GET /api/counter` (returns current total)
- Deploy on free tier (Vercel, Railway, Fly.io)

---

## 7. Monetization Implementation Details

### Ad Placement Strategy
**Banner Ads**:
- Fixed bottom banner (320x50)
- Appears after 2 minutes of app usage
- Disappears during active tapping (better UX)

**Interstitial Ads**:
- Full-screen ad after 5 consecutive minutes of use
- Max frequency: 1 per session if session < 10 minutes
- Skippable after 5 seconds

**Rewarded Video Ads** (Optional):
- Watch ad → unlock temporary premium casserole design
- Watch ad → 2x multiplier for global counter contribution

**Ad Removal IAP**:
- One-time purchase: €1.99
- Removes all ads permanently
- Highlight in settings with "Support the project" messaging

### Donation System
**UI Flow**:
1. "Support a Cause" button on main screen
2. Select donation amount (€1, €3, €5, custom)
3. Choose recipient organization (dropdown)
4. Payment via Google Pay / Apple Pay
5. 50% to developer, 50% to selected organization

**Payment Processing**:
- Stripe Connect or PayPal for developer split
- Transparent reporting in app (total donations, distribution)

**Supported Organizations** (Example List):
- Greenpeace
- Amnesty International
- Local French activist groups (e.g., Attac France)
- User-suggested organizations (community voting)

---

## 8. Development Roadmap

### Phase 1: MVP (Android) - 3-4 Weeks

**Week 1: Core Mechanics**
- [ ] Flutter project setup + dev environment
- [ ] Casserole widget with tap detection
- [ ] Spin animation (AnimationController)
- [ ] Audio system (5 sound variations)
- [ ] Haptic feedback integration
- [ ] Spark particle effect

**Week 2: Customization & Backend**
- [ ] Flag picker (10 flags)
- [ ] Center image picker (gallery/camera/presets)
- [ ] Settings screen
- [ ] Firebase setup (or REST API)
- [ ] Global counter integration (read/write)
- [ ] Local storage for user preferences

**Week 3: Monetization & Polish**
- [ ] AdMob integration (banner + interstitial)
- [ ] Ad removal IAP
- [ ] Donation UI + Stripe/PayPal setup
- [ ] Onboarding screens
- [ ] App icon + splash screen
- [ ] UI polish (animations, transitions)

**Week 4: Testing & Launch**
- [ ] Testing on physical device
- [ ] Performance optimization (60fps target)
- [ ] Privacy policy + terms of service
- [ ] Google Play Console setup
- [ ] App store listing (screenshots, description)
- [ ] Soft launch (friends/family testing)
- [ ] Public release on Google Play

**Deliverable**: La Casserole v1.0 live on Google Play Store

---

### Phase 2: iOS + Enhancements - 2-3 Weeks

**iOS Port**:
- [ ] iOS build configuration (Xcode)
- [ ] iOS-specific testing (haptics, audio)
- [ ] Apple App Store submission
- [ ] TestFlight beta testing

**Enhanced Features** (based on Android feedback):
- [ ] Additional casserole designs (bronze, copper, vintage)
- [ ] Sound pack DLC (wooden spoon, metal ladle variants)
- [ ] Protest event calendar integration
- [ ] Enhanced sharing (video recording of banging session)

---

### Phase 3: Web Version (Optional) - 1-2 Weeks
- [ ] Flutter web build
- [ ] Browser audio/haptic fallbacks (vibration API)
- [ ] Responsive design for desktop/mobile web
- [ ] Deploy to lacasserole.app domain

---

## 9. Success Metrics (KPIs)

### Launch Metrics (First 3 Months)
- **Downloads**: 10,000+ (Android)
- **DAU/MAU Ratio**: 20%+ (daily active users / monthly active users)
- **Avg Session Duration**: 2-5 minutes
- **Global Counter**: 1M+ bangs

### Monetization Metrics
- **Ad Revenue**: €200-500/month at 10K users
- **IAP Conversion**: 5-10% purchase ad removal
- **Donation Conversion**: 2-5% make at least one donation
- **Target Monthly Revenue**: €300-800 (modest goal for MVP)

### Engagement Metrics
- **Retention Day 1**: 40%+
- **Retention Day 7**: 20%+
- **Retention Day 30**: 10%+
- **Viral Coefficient**: 0.3+ (30% of users share)

---

## 10. Risk Assessment & Mitigation

### Technical Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Audio latency on older devices | Medium | Medium | Use low-latency audio libraries, test on range of devices |
| Backend cost scaling (counter) | Low | Low | Use free tier limits, batch writes efficiently |
| iOS App Store rejection | Medium | Low | Follow guidelines strictly, avoid political content in description |

### Market Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Niche audience limits growth | Medium | High | Expand to general "protest sounds" theme, international flags |
| Political backlash | Low | Low | Position as cultural/historical, not partisan |
| Competitor apps | Low | Low | First-mover advantage in French market, unique donation model |

### Monetization Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Low ad revenue | Medium | Medium | Diversify with IAP and donations |
| Donation processing complexity | Medium | Low | Use established payment processors (Stripe, PayPal) |

---

## 11. App Store Optimization (ASO)

### Google Play Store Listing

**App Name**: La Casserole - Protest Solidarity

**Short Description** (80 chars):
"Bang your casserole for protest solidarity! Join millions worldwide. 🥘✊"

**Full Description**:
```
La Casserole brings the iconic French protest tradition to your phone! Tap to spin your casserole, hear realistic metallic bangs, and join a global movement of solidarity.

✊ FEATURES:
• Realistic casserole simulation with physics-based spinning
• Multiple authentic bang sounds
• Haptic feedback for immersive experience
• Customize with flags from worldwide movements
• Add personal images to your casserole
• Track global bangs from protesters everywhere
• Support activist organizations through in-app donations

🇫🇷 CULTURAL HERITAGE:
The casserole (pot) has been a symbol of French protest since the 18th century. From Quebec's "casserole nights" to France's Yellow Vests, the sound of banging pots unites people demanding change.

🌍 GLOBAL SOLIDARITY:
Every tap contributes to a worldwide counter, showing the power of collective action. Whether you're at a demonstration or supporting from home, La Casserole lets you be heard.

💰 SUPPORT CAUSES:
50% of all donations go directly to activist organizations fighting for justice, environment, and human rights.

Bang for change. Bang for solidarity. Bang with La Casserole!
```

**Keywords**:
casserole, protest, manifestation, solidarity, activism, demonstration, revolution, france, pot, bang, activist, political, movement, strike

**Screenshots** (8 required):
1. Main screen with casserole (default)
2. Casserole mid-spin with sparks
3. Flag picker interface
4. Global counter milestone celebration
5. Custom image casserole
6. Donation screen
7. Settings screen
8. Onboarding screen

**Category**: Lifestyle or Entertainment
**Content Rating**: Everyone (no objectionable content)

---

## 12. Legal & Compliance

### Privacy Requirements
- **GDPR Compliance**: No personal data collection beyond optional donations
- **Privacy Policy**: Required for app stores
  - Cover: Image storage (local only), analytics (Firebase), ad tracking (AdMob)
- **Data Retention**: User preferences stored locally, no cloud storage of personal data

### Content Moderation
- User-uploaded images reviewed manually (if sharing enabled)
- Predefined flags/symbols vetted for non-extremist content
- Terms of Service prohibiting hate speech or violence advocacy

### Intellectual Property
- Sounds: Use royalty-free metallic impact samples (Freesound.org with attribution)
- Icons: Use open-source icon packs (Material Design, FontAwesome)
- Flags: Public domain flag images
- Casserole 3D model: Create original or use CC0 assets

---

## 13. Budget Estimate

### Development Costs (Solo Developer)
- **Time Investment**: 4-6 weeks @ 20-30 hrs/week = 80-180 hours
- **Opportunity Cost**: €0 (side project)

### Service Costs (Monthly)
- **Firebase**: €0 (free tier for MVP traffic)
- **Domain** (lacasserole.app): €15/year = €1.25/month
- **Google Play Developer**: €25 one-time
- **Apple Developer**: €99/year = €8.25/month (Phase 2)
- **Stripe/PayPal**: 2.9% + €0.30 per transaction

**Total Monthly**: ~€10 (Android only), ~€20 (iOS added)

### Break-Even Analysis
- Need €10-20/month to cover costs
- At 1,000 users with 5% IAP conversion: 50 purchases × €1.99 = €100/month
- **Break-even**: ~100-200 active users with modest IAP

---

## 14. Future Expansion Ideas (Post-MVP)

### Feature Enhancements
- **Casserole Collection**: Unlock different pot types (copper, cast iron, vintage)
- **Sound Packs**: Regional variations (African drums, Latin American cacerolazo)
- **AR Mode**: Place virtual casserole in real-world environment (ARCore/ARKit)
- **Protest Calendar**: Upcoming demonstrations, in-app event tracking
- **Leaderboard**: Top "bangers" by country/city (gamification)

### Platform Expansion
- **Web App**: Browser-based version for desktop activism
- **Smart Watch**: Apple Watch/Wear OS complications
- **Voice Assistants**: "Alexa, bang the casserole for [cause]"

### Community Features
- **User-Generated Content**: Submit custom casserole designs
- **Challenges**: Daily/weekly bang challenges with rewards
- **Social Network**: Connect with local activists, organize digital protests

---

## 15. Conclusion

**La Casserole** is a technically feasible, culturally resonant app with clear monetization paths and modest development scope. Leveraging your C++/Python expertise, Flutter provides an optimal balance of performance, cross-platform capability, and rapid development for this first mobile delivery.

**Key Success Factors**:
✅ Strong cultural hook (French protest tradition)
✅ Simple, addictive interaction (tap to bang)
✅ Global solidarity mechanic (counter)
✅ Low development complexity (3-4 weeks to launch)
✅ Multiple revenue streams (ads + IAP + donations)
✅ Scalable to iOS, web, and enhanced features

**Next Steps**:
1. ✅ Review and approve PRD
2. Set up Flutter development environment
3. Begin Phase 1 implementation
4. Iterative testing on your Android device

---

**Approval Signature**: ___________________
**Date**: ___________________
