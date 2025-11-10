# La Casserole - Technical Architecture Specification

**Version**: 1.0
**Date**: 2025-11-10
**Stack**: Flutter 3.16+ (Dart)

---

## 1. Technology Stack Overview

### Core Framework
```yaml
Framework: Flutter 3.16+
Language: Dart 3.2+
Target Platforms: Android 8.0+ (API 26+), iOS 12+ (Phase 2), Web (Phase 3)
IDE: Android Studio / VSCode with Flutter extensions
Build System: Gradle (Android), Xcode (iOS)
```

### Key Dependencies
```yaml
# pubspec.yaml structure

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.1.1              # Lightweight, proven for simple apps

  # Audio
  audioplayers: ^5.2.1          # Low-latency, well-maintained

  # Haptics
  vibration: ^1.8.4             # Cross-platform haptic feedback

  # Images
  image_picker: ^1.0.5          # Gallery/camera access
  image_cropper: ^5.0.1         # Circular crop for center image

  # Storage
  shared_preferences: ^2.2.2    # Local key-value storage

  # Backend
  firebase_core: ^2.24.2        # Firebase initialization
  firebase_database: ^10.4.0    # Realtime Database for counter
  firebase_analytics: ^10.7.4   # Usage analytics (optional)

  # Monetization
  google_mobile_ads: ^4.0.0     # AdMob integration
  in_app_purchase: ^3.1.11      # IAP for ad removal

  # Payment (Donations)
  stripe_payment: ^1.1.5        # Stripe SDK for donations

  # Utilities
  url_launcher: ^6.2.2          # Open URLs (privacy policy, etc.)
  package_info_plus: ^5.0.1     # App version info

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1         # Dart code linting
```

---

## 2. Architecture Pattern: Clean Architecture (Simplified)

### Directory Structure
```
casserole/
├── android/                    # Android-specific configuration
├── ios/                        # iOS-specific configuration (Phase 2)
├── lib/
│   ├── main.dart              # App entry point
│   ├── app.dart               # Material app configuration
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart      # App-wide constants
│   │   │   ├── asset_paths.dart        # Asset path strings
│   │   │   └── color_palette.dart      # Brand colors
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Material theme config
│   │   └── utils/
│   │       ├── haptic_utils.dart       # Haptic helper functions
│   │       └── audio_utils.dart        # Audio helper functions
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── flag_model.dart         # Flag data model
│   │   │   ├── casserole_state.dart    # Casserole configuration
│   │   │   └── counter_model.dart      # Global counter data
│   │   ├── repositories/
│   │   │   ├── counter_repository.dart # Counter backend abstraction
│   │   │   └── preferences_repository.dart # Local storage abstraction
│   │   └── services/
│   │       ├── audio_service.dart      # Audio playback logic
│   │       ├── haptic_service.dart     # Haptic feedback logic
│   │       ├── counter_service.dart    # Counter sync logic
│   │       ├── ad_service.dart         # AdMob logic
│   │       └── iap_service.dart        # In-app purchase logic
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── main_screen.dart        # Primary casserole screen
│   │   │   ├── settings_screen.dart    # Settings UI
│   │   │   ├── onboarding_screen.dart  # First-launch onboarding
│   │   │   └── donation_screen.dart    # Donation flow UI
│   │   ├── widgets/
│   │   │   ├── casserole_widget.dart   # Interactive casserole component
│   │   │   ├── spark_effect.dart       # Particle effect overlay
│   │   │   ├── flag_picker.dart        # Flag selection grid
│   │   │   ├── image_picker_dialog.dart # Center image picker
│   │   │   ├── global_counter.dart     # Counter display widget
│   │   │   └── ad_banner.dart          # Ad placement widget
│   │   └── providers/
│   │       ├── casserole_provider.dart # Casserole state management
│   │       ├── counter_provider.dart   # Counter state management
│   │       └── settings_provider.dart  # Settings state management
│   │
│   └── config/
│       ├── firebase_options.dart       # Firebase auto-generated config
│       └── admob_config.dart           # AdMob unit IDs
│
├── assets/
│   ├── audio/
│   │   ├── bang_01.mp3                 # Sound variation 1
│   │   ├── bang_02.mp3                 # Sound variation 2
│   │   ├── bang_03.mp3
│   │   ├── bang_04.mp3
│   │   └── bang_05.mp3
│   ├── images/
│   │   ├── casserole.png               # Main casserole image (2048x2048)
│   │   ├── flags/                      # Flag icons
│   │   │   ├── france.png
│   │   │   ├── rainbow.png
│   │   │   ├── black.png
│   │   │   └── ...
│   │   ├── symbols/                    # Predefined center images
│   │   │   ├── fist.png
│   │   │   ├── megaphone.png
│   │   │   └── ...
│   │   └── logo.png                    # App icon source
│   └── fonts/
│       └── (optional custom fonts)
│
├── test/
│   ├── unit/                           # Unit tests
│   └── widget/                         # Widget tests
│
├── pubspec.yaml                        # Dependencies and assets
├── analysis_options.yaml               # Linting rules
└── README.md                           # Project documentation
```

---

## 3. Core Components Design

### 3.1 Main Screen Architecture

```dart
// lib/presentation/screens/main_screen.dart

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(color: AppColors.background),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Top bar: flag + settings
                TopBar(),

                // Global counter
                GlobalCounter(),

                // Casserole (takes most space)
                Expanded(
                  child: Center(
                    child: CasseroleWidget(),
                  ),
                ),

                // Bottom actions
                BottomActions(),
              ],
            ),
          ),

          // Spark effects overlay
          SparkEffectOverlay(),

          // Ad banner (conditional)
          AdBanner(),
        ],
      ),
    );
  }
}
```

### 3.2 Casserole Widget (Core Interaction)

```dart
// lib/presentation/widgets/casserole_widget.dart

class CasseroleWidget extends StatefulWidget {
  @override
  _CasseroleWidgetState createState() => _CasseroleWidgetState();
}

class _CasseroleWidgetState extends State<CasseroleWidget>
    with SingleTickerProviderStateMixin {

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();

    // Spin animation setup
    _spinController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOut,
    );
  }

  void _onTap(Offset tapPosition) {
    // Trigger spin
    _spinController.forward(from: 0.0);

    // Play audio
    context.read<AudioService>().playRandomBang();

    // Trigger haptic
    context.read<HapticService>().mediumImpact();

    // Show sparks at tap position
    context.read<SparkProvider>().triggerSparks(tapPosition);

    // Increment counters
    context.read<CounterProvider>().incrementLocal();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTap(details.localPosition),
      child: AnimatedBuilder(
        animation: _spinAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _spinAnimation.value * 2 * pi, // Full rotation
            child: child,
          );
        },
        child: Consumer<CasseroleProvider>(
          builder: (context, provider, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Casserole base image
                Image.asset(
                  'assets/images/casserole.png',
                  width: 300,
                  height: 300,
                ),

                // Center image (if set)
                if (provider.centerImage != null)
                  ClipOval(
                    child: Image.file(
                      provider.centerImage!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }
}
```

### 3.3 Spark Effect System

```dart
// lib/presentation/widgets/spark_effect.dart

class SparkEffectOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SparkProvider>(
      builder: (context, provider, _) {
        return Stack(
          children: provider.activeSparks.map((spark) {
            return SparkParticle(spark: spark);
          }).toList(),
        );
      },
    );
  }
}

class SparkParticle extends StatefulWidget {
  final Spark spark;

  const SparkParticle({required this.spark});

  @override
  _SparkParticleState createState() => _SparkParticleState();
}

class _SparkParticleState extends State<SparkParticle>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(_controller);

    _controller.forward().then((_) {
      // Remove spark after animation
      context.read<SparkProvider>().removeSpark(widget.spark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.spark.position.dx,
      top: widget.spark.position.dy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.orange, Colors.yellow],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Spark data model
class Spark {
  final Offset position;
  final String id;

  Spark({required this.position}) : id = Uuid().v4();
}
```

### 3.4 Audio Service

```dart
// lib/data/services/audio_service.dart

class AudioService {
  final List<AudioPlayer> _players = [];
  final Random _random = Random();

  static const List<String> _soundPaths = [
    'audio/bang_01.mp3',
    'audio/bang_02.mp3',
    'audio/bang_03.mp3',
    'audio/bang_04.mp3',
    'audio/bang_05.mp3',
  ];

  Future<void> initialize() async {
    // Pre-load audio files for low latency
    for (var path in _soundPaths) {
      final player = AudioPlayer();
      await player.setSource(AssetSource(path));
      await player.setVolume(1.0);
      _players.add(player);
    }
  }

  Future<void> playRandomBang() async {
    final index = _random.nextInt(_soundPaths.length);
    final player = _players[index];

    // Reset and play
    await player.seek(Duration.zero);
    await player.resume();
  }

  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
  }
}
```

### 3.5 Haptic Service

```dart
// lib/data/services/haptic_service.dart

class HapticService {
  final Vibration _vibration = Vibration();

  Future<void> mediumImpact() async {
    if (await _vibration.hasVibrator() ?? false) {
      await _vibration.vibrate(duration: 50); // 50ms medium impact
    }
  }
}
```

### 3.6 Counter Service (Firebase Backend)

```dart
// lib/data/services/counter_service.dart

class CounterService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final _localCounterQueue = <int>[];
  Timer? _syncTimer;

  // Reference to global counter node
  DatabaseReference get _counterRef => _database.ref('global_counter');

  void startSync() {
    // Sync queued taps every 10 seconds
    _syncTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _flushQueue();
    });
  }

  void incrementLocal() {
    _localCounterQueue.add(1);

    // Flush if queue reaches 10 taps
    if (_localCounterQueue.length >= 10) {
      _flushQueue();
    }
  }

  Future<void> _flushQueue() async {
    if (_localCounterQueue.isEmpty) return;

    final count = _localCounterQueue.length;
    _localCounterQueue.clear();

    try {
      // Atomic increment
      await _counterRef.runTransaction((currentValue) {
        final current = (currentValue ?? 0) as int;
        return Transaction.success(current + count);
      });
    } catch (e) {
      // Re-queue on failure
      _localCounterQueue.addAll(List.filled(count, 1));
    }
  }

  Stream<int> watchCounter() {
    return _counterRef.onValue.map((event) {
      return (event.snapshot.value ?? 0) as int;
    });
  }

  void dispose() {
    _syncTimer?.cancel();
    _flushQueue(); // Final flush
  }
}
```

### 3.7 Global Counter Widget

```dart
// lib/presentation/widgets/global_counter.dart

class GlobalCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CounterProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Global Bangs',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _formatCounter(provider.globalCount),
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatCounter(int count) {
    // Format with commas: 1234567 -> 1,234,567
    return NumberFormat('#,###').format(count);
  }
}
```

---

## 4. State Management Architecture

### Provider Pattern Implementation

```dart
// lib/presentation/providers/casserole_provider.dart

class CasseroleProvider extends ChangeNotifier {
  File? _centerImage;
  String _selectedFlag = 'france';

  File? get centerImage => _centerImage;
  String get selectedFlag => _selectedFlag;

  void setFlag(String flagKey) {
    _selectedFlag = flagKey;
    _savePreferences();
    notifyListeners();
  }

  Future<void> pickCenterImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Crop to circle
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        cropStyle: CropStyle.circle,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (croppedFile != null) {
        _centerImage = File(croppedFile.path);
        _savePreferences();
        notifyListeners();
      }
    }
  }

  void clearCenterImage() {
    _centerImage = null;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_flag', _selectedFlag);
    if (_centerImage != null) {
      await prefs.setString('center_image_path', _centerImage!.path);
    } else {
      await prefs.remove('center_image_path');
    }
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedFlag = prefs.getString('selected_flag') ?? 'france';
    final imagePath = prefs.getString('center_image_path');
    if (imagePath != null && await File(imagePath).exists()) {
      _centerImage = File(imagePath);
    }
    notifyListeners();
  }
}
```

```dart
// lib/presentation/providers/counter_provider.dart

class CounterProvider extends ChangeNotifier {
  final CounterService _counterService;
  int _globalCount = 0;
  int _localCount = 0;

  CounterProvider(this._counterService) {
    _initialize();
  }

  int get globalCount => _globalCount;
  int get localCount => _localCount;

  void _initialize() {
    // Listen to global counter updates
    _counterService.watchCounter().listen((count) {
      _globalCount = count;
      notifyListeners();
    });

    // Start background sync
    _counterService.startSync();
  }

  void incrementLocal() {
    _localCount++;
    _counterService.incrementLocal();

    // Optimistic update (estimate global)
    _globalCount++;
    notifyListeners();
  }
}
```

---

## 5. Backend Architecture (Firebase)

### Firebase Realtime Database Schema

```json
{
  "global_counter": 1234567,
  "metadata": {
    "last_updated": "2025-11-10T14:30:00Z",
    "version": "1.0"
  }
}
```

### Firebase Rules (Security)

```json
{
  "rules": {
    "global_counter": {
      ".read": true,
      ".write": true,
      ".validate": "newData.isNumber() && newData.val() >= data.val()"
    },
    "metadata": {
      ".read": true,
      ".write": false
    }
  }
}
```

### Alternative: REST API Backend (Optional)

If avoiding Firebase complexity:

```python
# Simple Flask API for counter (deploy on Vercel/Railway)

from flask import Flask, jsonify, request
from flask_cors import CORS
import redis

app = Flask(__name__)
CORS(app)

# Redis for counter storage
redis_client = redis.Redis(
    host='redis-hostname',
    port=6379,
    decode_responses=True
)

COUNTER_KEY = 'global_counter'

@app.route('/api/counter', methods=['GET'])
def get_counter():
    count = redis_client.get(COUNTER_KEY) or 0
    return jsonify({'count': int(count)})

@app.route('/api/bang', methods=['POST'])
def increment_counter():
    data = request.json
    increment = data.get('increment', 1)

    new_count = redis_client.incrby(COUNTER_KEY, increment)
    return jsonify({'count': new_count})

if __name__ == '__main__':
    app.run()
```

---

## 6. Monetization Integration

### 6.1 AdMob Setup

```dart
// lib/data/services/ad_service.dart

class AdService {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isAdRemovalPurchased = false;

  static const String bannerAdUnitId = 'ca-app-pub-xxxxx'; // Replace with real ID
  static const String interstitialAdUnitId = 'ca-app-pub-xxxxx';

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadAdRemovalStatus();

    if (!_isAdRemovalPurchased) {
      _loadBannerAd();
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => print('Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner failed: $error');
        },
      ),
    );
    _bannerAd?.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('Interstitial failed: $error');
        },
      ),
    );
  }

  void showInterstitial() {
    if (_isAdRemovalPurchased || _interstitialAd == null) return;

    _interstitialAd?.show();
    _interstitialAd = null;
    _loadInterstitialAd(); // Reload for next time
  }

  BannerAd? get bannerAd => _isAdRemovalPurchased ? null : _bannerAd;

  Future<void> _loadAdRemovalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdRemovalPurchased = prefs.getBool('ad_removal_purchased') ?? false;
  }

  Future<void> markAdRemovalPurchased() async {
    _isAdRemovalPurchased = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ad_removal_purchased', true);

    _bannerAd?.dispose();
    _interstitialAd?.dispose();
  }
}
```

### 6.2 In-App Purchase (Ad Removal)

```dart
// lib/data/services/iap_service.dart

class IAPService {
  final InAppPurchase _iap = InAppPurchase.instance;
  static const String adRemovalProductId = 'ad_removal';

  Future<void> purchaseAdRemoval(BuildContext context) async {
    final available = await _iap.isAvailable();
    if (!available) {
      _showError(context, 'In-app purchases not available');
      return;
    }

    final response = await _iap.queryProductDetails({adRemovalProductId});
    if (response.productDetails.isEmpty) {
      _showError(context, 'Product not found');
      return;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);

    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void listenToPurchases(BuildContext context) {
    _iap.purchaseStream.listen((purchases) {
      for (var purchase in purchases) {
        if (purchase.productID == adRemovalProductId &&
            purchase.status == PurchaseStatus.purchased) {
          _handleAdRemovalPurchase(context);
        }
      }
    });
  }

  Future<void> _handleAdRemovalPurchase(BuildContext context) async {
    await context.read<AdService>().markAdRemovalPurchased();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Thank you! Ads removed.')),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
```

---

## 7. Performance Optimization

### 7.1 Asset Optimization
- **Casserole Image**: 2048x2048 PNG → compress to ~500KB (TinyPNG)
- **Audio Files**: 44.1kHz MP3 → compress to ~50KB each (Audacity)
- **Flag Icons**: 256x256 PNG → compress to ~20KB each

### 7.2 Animation Performance
- Use `RepaintBoundary` around casserole to isolate repaints
- Pre-cache images with `precacheImage()`
- Limit spark particles to 12 per tap
- Use `const` constructors where possible

### 7.3 Memory Management
- Dispose animation controllers in `dispose()`
- Clear spark list after animations complete
- Limit audio player pool to 5 instances
- Use `Image.asset()` caching for flags

### 7.4 Network Optimization
- Batch counter increments (10 taps or 10 seconds)
- Use Firebase offline persistence
- Implement exponential backoff for failed syncs

---

## 8. Testing Strategy

### 8.1 Unit Tests
```dart
// test/unit/counter_service_test.dart

void main() {
  group('CounterService', () {
    test('increments local counter', () {
      final service = CounterService();
      service.incrementLocal();
      expect(service.localCounterQueue.length, 1);
    });

    test('flushes queue at 10 taps', () async {
      final service = CounterService();
      for (int i = 0; i < 10; i++) {
        service.incrementLocal();
      }
      // Verify flush triggered
    });
  });
}
```

### 8.2 Widget Tests
```dart
// test/widget/casserole_widget_test.dart

void main() {
  testWidgets('Casserole spins on tap', (tester) async {
    await tester.pumpWidget(MyApp());

    final casserole = find.byType(CasseroleWidget);
    await tester.tap(casserole);
    await tester.pump();

    // Verify animation started
    expect(find.byType(RotationTransition), findsOneWidget);
  });
}
```

### 8.3 Integration Tests
- Test full flow: launch → tap → counter update → settings
- Test ad display after 2 minutes
- Test IAP purchase flow (sandbox)

---

## 9. Build & Deployment

### 9.1 Android Build Configuration

```gradle
// android/app/build.gradle

android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.lacasserole.app"
        minSdkVersion 26  // Android 8.0+
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 9.2 Release Build Steps
```bash
# 1. Generate keystore (one-time)
keytool -genkey -v -keystore lacasserole.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000

# 2. Configure signing in android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=release
storeFile=lacasserole.keystore

# 3. Build release APK
flutter build apk --release

# 4. Build App Bundle (for Play Store)
flutter build appbundle --release
```

### 9.3 Continuous Integration (Optional)
- GitHub Actions for automated builds
- Firebase App Distribution for beta testing
- Fastlane for automated deployment

---

## 10. Security Considerations

### 10.1 Firebase Security
- Use Firebase App Check to prevent abuse
- Rate limit counter increments (max 100/minute per device)
- Monitor for anomalous traffic patterns

### 10.2 API Keys Protection
- Store AdMob IDs in `admob_config.dart` (not in git)
- Use environment variables for sensitive keys
- Enable ProGuard/R8 obfuscation for release builds

### 10.3 User Data Privacy
- No personal data collection beyond optional donations
- Clear privacy policy accessible from settings
- GDPR-compliant (minimal data processing)

---

## 11. Monitoring & Analytics

### 11.1 Firebase Analytics Events
```dart
// Track key user actions
FirebaseAnalytics.instance.logEvent(
  name: 'casserole_tap',
  parameters: {'tap_count': localCount},
);

FirebaseAnalytics.instance.logEvent(
  name: 'flag_changed',
  parameters: {'flag': flagKey},
);

FirebaseAnalytics.instance.logEvent(
  name: 'donation_initiated',
  parameters: {'amount': donationAmount},
);
```

### 11.2 Crash Reporting
- Firebase Crashlytics for production crash tracking
- Sentry (alternative, more detailed)

### 11.3 Performance Monitoring
- Firebase Performance Monitoring
- Track app startup time, frame rates, network requests

---

## 12. Development Environment Setup

### Prerequisites
```bash
# Install Flutter
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"

# Install Android SDK (if not already)
sudo apt-get install android-sdk

# Accept licenses
flutter doctor --android-licenses

# Verify setup
flutter doctor -v
```

### Initial Project Setup
```bash
# Create Flutter project
flutter create casserole --org com.lacasserole

cd casserole

# Add dependencies
flutter pub add provider audioplayers vibration image_picker image_cropper shared_preferences firebase_core firebase_database firebase_analytics google_mobile_ads in_app_purchase url_launcher package_info_plus

# Run on connected device
flutter run
```

---

## 13. Conclusion

This architecture provides:
✅ **Scalability**: Clean separation of concerns for easy feature additions
✅ **Performance**: Optimized animations, audio, and network operations
✅ **Maintainability**: Clear structure with Provider state management
✅ **Cross-platform**: Flutter enables iOS/web expansion with minimal changes
✅ **Monetization**: Integrated ad and IAP systems from day one

**Next Steps**:
1. Set up Flutter development environment
2. Initialize project with dependencies
3. Implement core casserole interaction (Week 1)
4. Build monetization and backend (Weeks 2-3)
5. Test, polish, and deploy (Week 4)

---

**Reviewed By**: ___________________
**Date**: ___________________
