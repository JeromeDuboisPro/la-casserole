# Week 1 Implementation Checklist: Core Mechanics

**Goal**: Build interactive casserole with tap → spin → sound → haptic → sparks
**Timeline**: 5-7 days
**Test Device**: Your Android phone

---

## Day 1: Environment Setup & Project Initialization

### Morning: Flutter Setup
- [ ] Run `flutter doctor -v` and resolve all issues
- [ ] Accept Android licenses: `flutter doctor --android-licenses`
- [ ] Connect Android phone and verify: `flutter devices`
- [ ] Create Flutter project: `flutter create . --org com.lacasserole`

### Afternoon: Dependencies & Structure
- [ ] Edit `pubspec.yaml` with all dependencies (see Quick Start)
- [ ] Run `flutter pub get`
- [ ] Create directory structure:
  ```bash
  mkdir -p lib/{core/{constants,theme,utils},data/{models,services},presentation/{screens,widgets,providers}}
  mkdir -p assets/{audio,images}
  ```
- [ ] Run test app on phone: `flutter run`
- [ ] Git commit: "🎉 Initial Flutter project setup"

### Evening: Asset Preparation
- [ ] Download 5 metallic bang sounds → `assets/audio/bang_0X.mp3`
- [ ] Create/find casserole image (2048x2048) → `assets/images/casserole.png`
- [ ] Update `pubspec.yaml` assets section
- [ ] Test asset loading with simple UI
- [ ] Git commit: "📦 Add audio and image assets"

---

## Day 2: Core Casserole Widget

### Morning: Basic Widget Structure
- [ ] Create `lib/presentation/widgets/casserole_widget.dart`
- [ ] Implement StatefulWidget with SingleTickerProviderStateMixin
- [ ] Add casserole image display (300x300)
- [ ] Implement GestureDetector for tap detection
- [ ] Test tap detection with print statements
- [ ] Git commit: "✨ feat: Basic casserole widget with tap detection"

### Afternoon: Spin Animation
- [ ] Create AnimationController (1500ms duration)
- [ ] Implement CurvedAnimation with Curves.easeOut
- [ ] Add Transform.rotate with animation value
- [ ] Connect tap to animation trigger: `_spinController.forward(from: 0.0)`
- [ ] Test smooth spin on tap
- [ ] Git commit: "🎨 feat: Add casserole spin animation"

### Evening: Animation Polish
- [ ] Add RepaintBoundary for optimization
- [ ] Implement tap queueing (max 3 queued spins)
- [ ] Test rapid tapping behavior
- [ ] Add animation dispose in widget dispose
- [ ] Git commit: "♻️ refactor: Optimize spin animation with queuing"

---

## Day 3: Audio System

### Morning: Audio Service Setup
- [ ] Create `lib/data/services/audio_service.dart`
- [ ] Implement AudioService class with audioplayers package
- [ ] Pre-load all 5 audio files in initialize()
- [ ] Create `playRandomBang()` method with random selection
- [ ] Test audio playback independently
- [ ] Git commit: "🔊 feat: Audio service with multi-sample playback"

### Afternoon: Audio Integration
- [ ] Add AudioService initialization in main.dart
- [ ] Connect casserole tap to `playRandomBang()`
- [ ] Test audio plays on every tap
- [ ] Handle audio latency issues if any (use low-latency mode)
- [ ] Test with headphones and speaker
- [ ] Git commit: "🎵 feat: Integrate audio with casserole interaction"

### Evening: Audio Polish
- [ ] Implement proper audio disposal
- [ ] Add volume control (respect system volume)
- [ ] Test audio doesn't overlap badly
- [ ] Handle edge case: app in background
- [ ] Git commit: "✅ test: Audio system edge cases and cleanup"

---

## Day 4: Haptic Feedback

### Morning: Haptic Service
- [ ] Create `lib/data/services/haptic_service.dart`
- [ ] Implement HapticService with vibration package
- [ ] Add `mediumImpact()` method (50ms vibration)
- [ ] Test haptic on Android phone
- [ ] Handle case: device doesn't support haptics
- [ ] Git commit: "📳 feat: Haptic feedback service"

### Afternoon: Haptic Integration
- [ ] Connect haptic to casserole tap (same trigger as audio)
- [ ] Synchronize haptic with animation start
- [ ] Test feel: adjust duration if needed (30-70ms range)
- [ ] Test with audio simultaneously
- [ ] Git commit: "✨ feat: Integrate haptic with tap interaction"

### Evening: Multi-Sensory Polish
- [ ] Fine-tune timing: tap → spin + audio + haptic simultaneously
- [ ] Test overall experience on phone
- [ ] Adjust haptic intensity if too strong/weak
- [ ] Verify no lag between tap and feedback
- [ ] Git commit: "🎯 polish: Synchronize animation, audio, and haptics"

---

## Day 5: Spark Particle Effects

### Morning: Spark Data Model & Provider
- [ ] Create `lib/data/models/spark_model.dart`
- [ ] Define Spark class: `{Offset position, String id}`
- [ ] Create `lib/presentation/providers/spark_provider.dart`
- [ ] Implement triggerSparks(Offset position) method
- [ ] Generate 8-12 random spark positions around tap point
- [ ] Git commit: "✨ feat: Spark data model and provider"

### Afternoon: Spark Widget
- [ ] Create `lib/presentation/widgets/spark_effect.dart`
- [ ] Implement SparkEffectOverlay (Stack of spark particles)
- [ ] Create SparkParticle widget with AnimationController
- [ ] Implement fade-out + scale-up animation (400ms)
- [ ] Add orange/yellow gradient circle (8px diameter)
- [ ] Git commit: "💥 feat: Spark particle widget with animations"

### Evening: Spark Integration
- [ ] Add SparkEffectOverlay to MainScreen Stack
- [ ] Connect tap to `triggerSparks(tapPosition)`
- [ ] Test sparks appear at tap location
- [ ] Verify sparks disappear after animation
- [ ] Test rapid tapping: multiple spark sets
- [ ] Git commit: "🎆 feat: Integrate spark effects with tap interaction"

---

## Day 6: Main Screen Layout

### Morning: Screen Structure
- [ ] Create `lib/presentation/screens/main_screen.dart`
- [ ] Implement Scaffold with SafeArea
- [ ] Add top bar placeholder (flag + settings icons)
- [ ] Add CasseroleWidget in Expanded Center
- [ ] Add bottom action placeholders
- [ ] Git commit: "🏗️ feat: Main screen layout structure"

### Afternoon: UI Polish
- [ ] Create `lib/core/theme/app_theme.dart`
- [ ] Define brand colors (orange accent, dark background)
- [ ] Apply theme to MaterialApp
- [ ] Add gradient background or solid color
- [ ] Test layout on different screen sizes (if possible)
- [ ] Git commit: "🎨 feat: App theme and color palette"

### Evening: Provider Setup
- [ ] Create `lib/presentation/providers/casserole_provider.dart`
- [ ] Implement basic state (selected flag, center image)
- [ ] Wrap app with MultiProvider in main.dart
- [ ] Provide AudioService, HapticService
- [ ] Test provider access in widgets
- [ ] Git commit: "🔌 feat: Provider state management setup"

---

## Day 7: Testing & Polish

### Morning: Integration Testing
- [ ] Test complete flow: launch → tap → spin + audio + haptic + sparks
- [ ] Test on your Android phone (not just emulator)
- [ ] Check performance: 60fps during animation?
- [ ] Test battery impact (should be negligible)
- [ ] Test with different system volume levels
- [ ] Git commit: "✅ test: End-to-end core mechanics validation"

### Afternoon: Bug Fixes & Optimization
- [ ] Fix any discovered bugs
- [ ] Optimize spark count if performance issues (reduce to 6-8)
- [ ] Add comments to complex code sections
- [ ] Clean up debug prints
- [ ] Run `flutter analyze` and fix warnings
- [ ] Git commit: "🐛 fix: Core mechanics bugs and optimizations"

### Evening: Week 1 Wrap-Up
- [ ] Create demo video (30 sec) on phone
- [ ] Update README with Week 1 progress
- [ ] Push all commits to GitHub
- [ ] Celebrate: Core interaction is DONE! 🎉
- [ ] Git commit: "📝 docs: Week 1 completion - core mechanics ready"

---

## Week 1 Success Criteria

**Must Have**:
- ✅ Casserole displays on screen
- ✅ Tap triggers continuous spin animation
- ✅ Random bang sound plays on tap
- ✅ Haptic feedback on tap
- ✅ Spark particles appear at tap location
- ✅ All effects synchronized (no lag)
- ✅ App runs smoothly on Android phone (60fps)

**Bonus (if time permits)**:
- ⭐ Casserole shadow/lighting effects
- ⭐ More spark variations (different colors)
- ⭐ Tap counter displayed (local only)
- ⭐ Background ambient audio (optional)

---

## Testing Checklist

Test these scenarios on your Android phone:

### Basic Interaction
- [ ] Single tap → spin + sound + haptic + sparks
- [ ] Multiple rapid taps → queued spins work
- [ ] Tap during spin → new spin queues properly
- [ ] Long press → same as tap (no special behavior)

### Audio
- [ ] Sound plays immediately (< 50ms latency)
- [ ] Different sounds on consecutive taps
- [ ] Audio respects system volume
- [ ] Mute mode → no audio (haptic still works)

### Haptics
- [ ] Haptic feels satisfying (not too weak/strong)
- [ ] Haptic works in silent mode
- [ ] Older devices: graceful degradation if no haptic

### Performance
- [ ] No frame drops during animation
- [ ] Sparks don't cause lag
- [ ] App doesn't crash on rapid tapping
- [ ] Memory usage stable (no leaks)

### Edge Cases
- [ ] App in background → pause audio
- [ ] App resumed → everything works
- [ ] Phone rotation → layout adapts (or lock portrait)
- [ ] Low battery → no extra drain

---

## Git Commit Pattern

Use conventional commits with emojis:

```bash
git commit -m "✨ feat: Add casserole spin animation

- Implemented AnimationController for 360° rotation
- Used Curves.easeOut for natural deceleration
- Added tap queueing for smooth experience

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Commit Types**:
- `feat` ✨: New feature
- `fix` 🐛: Bug fix
- `refactor` ♻️: Code restructuring
- `test` ✅: Testing
- `docs` 📝: Documentation
- `style` 💄: UI/styling
- `perf` ⚡: Performance improvement
- `chore` 🔧: Maintenance

---

## Troubleshooting

### Audio Issues
```bash
# If audio doesn't play:
1. Check assets are in pubspec.yaml
2. Run: flutter clean && flutter pub get
3. Verify audio files are valid MP3s
4. Test with audioplayers example app
```

### Animation Lag
```bash
# If animation stutters:
1. Add RepaintBoundary around casserole
2. Use flutter run --profile to measure
3. Reduce spark particle count
4. Optimize image size (compress casserole.png)
```

### Haptic Not Working
```bash
# If haptic doesn't work:
1. Check phone supports vibration
2. Verify permissions in AndroidManifest.xml
3. Test with vibration package example
4. Try different durations (30ms, 50ms, 70ms)
```

---

## Week 2 Preview

After Week 1, you'll move to **Customization & Backend**:
- Flag picker (10 flags)
- Center image picker (gallery/camera)
- Settings screen
- Firebase setup
- Global counter integration

But for now, focus on nailing the core interaction! 🎯

---

**Let's build something that makes noise! 🥘🔊**
