# Asset Preparation Checklist

**Status**: 🔄 In Progress
**Priority**: Complete before Day 2 implementation

---

## 📁 Directory Structure ✅

```
assets/
├── audio/              ✅ Created
├── images/             ✅ Created
│   ├── flags/          ✅ Created
│   └── symbols/        ✅ Created
```

---

## 🔊 Audio Files (5 metallic bang sounds)

**Format**: MP3
**Size**: ~50KB each
**Sample Rate**: 44.1kHz

### Sources:
1. **Freesound.org** (recommended, free with attribution)
   - Search: "metal pot bang" or "metal impact" or "pan bang"
   - URL: https://freesound.org/search/?q=metal+pot+bang
   - Filter: License → CC0 (no attribution needed) or CC-BY (attribution required)

2. **ZapSplat.com** (free with account)
   - URL: https://www.zapsplat.com/
   - Search: "metal pot" or "cookware impact"

### Required Files:
- [ ] `assets/audio/bang_01.mp3`
- [ ] `assets/audio/bang_02.mp3`
- [ ] `assets/audio/bang_03.mp3`
- [ ] `assets/audio/bang_04.mp3`
- [ ] `assets/audio/bang_05.mp3`

### Quick Download Commands (if you have direct URLs):
```bash
cd assets/audio/

# Example (replace with actual URLs):
# wget -O bang_01.mp3 "https://freesound.org/data/previews/xxx.mp3"
# wget -O bang_02.mp3 "https://freesound.org/data/previews/yyy.mp3"
# ... repeat for bang_03-05.mp3
```

---

## 🥘 Casserole Image

**Format**: PNG
**Size**: 2048x2048 pixels
**File Size**: <500KB (after compression)
**Background**: Transparent or solid color

### Options:

#### Option 1: Find Existing Image
- **Unsplash.com**: https://unsplash.com/s/photos/pot
- **Pexels.com**: https://www.pexels.com/search/pot/
- Search: "pot", "casserole", "pan", "cookware"
- Download high-res, crop to square, resize to 2048x2048

#### Option 2: Generate with AI
- **DALL-E** or **Midjourney**: "Realistic metal casserole pot, top-down view, transparent background, 3D render"
- **Stable Diffusion**: "Metal cooking pot, professional product photo, white background"

#### Option 3: Simple Placeholder (for testing)
Use this command to create a simple test image:
```bash
# Install ImageMagick if needed: sudo dnf install ImageMagick
convert -size 2048x2048 xc:lightgray \
  -gravity center \
  -pointsize 200 \
  -draw "circle 1024,1024 1024,200" \
  -draw "text 0,0 '🥘'" \
  assets/images/casserole.png
```

### Required File:
- [ ] `assets/images/casserole.png` (2048x2048)

### Compression (after getting image):
```bash
# Online: https://tinypng.com/
# Or use ImageMagick:
convert assets/images/casserole.png -quality 85 -resize 2048x2048 assets/images/casserole.png
```

---

## 🚩 Flag Icons (10-15 flags minimum)

**Format**: PNG
**Size**: 256x256 pixels
**File Size**: ~20KB each

### Sources:
1. **Flagpedia.net**: https://flagpedia.net/
   - Download PNG icons (256x256)
   - Public domain

2. **Flaticon.com**: https://www.flaticon.com/packs/countrys-flags
   - Free with attribution

3. **Wikipedia Commons**: High-quality SVG flags (can convert to PNG)

### Required Flags (Priority Order):

#### Essential (5 flags):
- [ ] `assets/images/flags/france.png` - French tricolor
- [ ] `assets/images/flags/rainbow.png` - LGBTQ+ pride
- [ ] `assets/images/flags/black.png` - Anarchist/antifa
- [ ] `assets/images/flags/red.png` - Socialist/labor
- [ ] `assets/images/flags/green.png` - Environmental

#### Important (5 more):
- [ ] `assets/images/flags/palestine.png`
- [ ] `assets/images/flags/ukraine.png`
- [ ] `assets/images/flags/catalonia.png`
- [ ] `assets/images/flags/brittany.png`
- [ ] `assets/images/flags/basque.png`

#### Optional (5 more):
- [ ] `assets/images/flags/european_union.png`
- [ ] `assets/images/flags/feminism.png` (purple)
- [ ] `assets/images/flags/peace.png` (white dove)
- [ ] `assets/images/flags/indigenous.png`
- [ ] `assets/images/flags/disability.png`

### Quick Download Script (example):
```bash
cd assets/images/flags/

# France
wget -O france.png "https://flagcdn.com/256x192/fr.png"

# Add more wget commands for other flags...
```

---

## 🎨 Symbol Images (5-10 preset center images)

**Format**: PNG
**Size**: 256x256 pixels (circular)
**Background**: Transparent

### Required Symbols:

- [ ] `assets/images/symbols/fist.png` - Raised fist
- [ ] `assets/images/symbols/megaphone.png` - Megaphone
- [ ] `assets/images/symbols/peace.png` - Peace sign
- [ ] `assets/images/symbols/star.png` - Red star
- [ ] `assets/images/symbols/heart.png` - Solidarity heart

### Sources:
- **The Noun Project**: https://thenounproject.com/ (free with attribution)
- **Flaticon**: https://www.flaticon.com/
- **Material Icons**: https://fonts.google.com/icons

---

## 📝 Update pubspec.yaml

After downloading assets, add this to `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true

  assets:
    - assets/audio/
    - assets/images/
    - assets/images/flags/
    - assets/images/symbols/
```

Then run:
```bash
flutter pub get
```

---

## ✅ Verification Checklist

Before proceeding to Day 2:

### Audio
- [ ] 5 MP3 files in `assets/audio/`
- [ ] Each file ~50KB
- [ ] Files named: bang_01.mp3 through bang_05.mp3
- [ ] Test play one file: `mpv assets/audio/bang_01.mp3`

### Images
- [ ] Casserole image: `assets/images/casserole.png`
- [ ] Image size: 2048x2048 pixels
- [ ] File size: <500KB
- [ ] Test view: `eog assets/images/casserole.png`

### Flags
- [ ] At least 5 flag PNGs in `assets/images/flags/`
- [ ] Files named: france.png, rainbow.png, etc.
- [ ] Each ~256x256 pixels
- [ ] Total ~100-300KB

### Symbols (optional for MVP)
- [ ] At least 3 symbol PNGs in `assets/images/symbols/`
- [ ] Each ~256x256 pixels
- [ ] Transparent backgrounds

### Configuration
- [ ] `pubspec.yaml` updated with assets section
- [ ] Run `flutter pub get` successfully
- [ ] No errors in asset loading

---

## 🚀 Quick Start Option: Use Placeholders

If you want to start coding immediately without perfect assets:

```bash
# Create simple text-based placeholders for testing
cd assets/audio/
for i in {01..05}; do touch bang_$i.mp3; done

cd ../images/
# Download a quick test casserole image
wget -O casserole.png "https://via.placeholder.com/2048/CCCCCC/000000?text=Casserole"

cd flags/
# Download France flag as test
wget -O france.png "https://flagcdn.com/256x192/fr.png"

cd ../symbols/
# Create placeholder
wget -O fist.png "https://via.placeholder.com/256/FF0000/FFFFFF?text=Fist"
```

**Note**: Replace placeholders with real assets before final release!

---

## 📊 Progress Tracking

**Overall Asset Completion**: __% (update as you add files)

| Category | Required | Downloaded | Status |
|----------|----------|------------|--------|
| Audio    | 5        | 0          | ⏳ Pending |
| Casserole| 1        | 0          | ⏳ Pending |
| Flags    | 10       | 0          | ⏳ Pending |
| Symbols  | 5        | 0          | ⏳ Pending |
| Config   | 1        | 0          | ⏳ Pending |

---

**Next**: Once assets are ready, proceed to Day 2 implementation! 🚀
