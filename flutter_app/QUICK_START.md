# Quick Setup Guide for Mood Mirror

## 🚀 Super Quick Start (3 Steps!)

### 1️⃣ Install Flutter (First Time Only)

**Windows:**
1. Download Flutter: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add to PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\flutter\bin`
4. Open new terminal and run: `flutter doctor`

### 2️⃣ Install Android SDK (First Time Only)

**Option A - Android Studio (Recommended):**
1. Download: https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio
4. Go to: Tools > SDK Manager
5. Install: Android SDK 34

**Option B - Command Line Tools:**
1. Download: https://developer.android.com/studio#command-tools
2. Extract and add to PATH
3. Run: `flutter doctor --android-licenses` (accept all)

### 3️⃣ Build Your APK!

```powershell
# Navigate to project
cd "C:\Users\saini\Documents\SkilliZee\MoodMirror\mood-mirror-1\flutter_app"

# Easy way - Run the build script
.\build_apk.ps1

# OR Manual way
flutter pub get
flutter build apk --release
```

**That's it!** 🎉

Your APK will be at: `build\app\outputs\flutter-apk\app-release.apk`

---

## 📱 Installing on Your Phone

### Method 1: USB Cable
1. Enable Developer Options on your phone
   - Settings > About Phone > Tap "Build Number" 7 times
2. Enable USB Debugging
   - Settings > Developer Options > USB Debugging
3. Connect phone to PC
4. Run: `flutter install`

### Method 2: Direct Transfer
1. Copy `app-release.apk` to your phone
2. Open the file on your phone
3. Allow "Install from Unknown Sources" if prompted
4. Tap Install
5. Open Mood Mirror app
6. Allow Camera permission
7. Start detecting emotions! 😊

---

## ⚡ One-Line Build Commands

```powershell
# Quick build (release)
flutter build apk --release

# Quick build (debug, faster)
flutter build apk --debug

# Smallest APK (split per CPU type)
flutter build apk --split-per-abi --release

# Run directly on phone
flutter run --release
```

---

## 🔧 First-Time Setup Checklist

- [ ] Flutter installed
- [ ] Flutter added to PATH
- [ ] Android SDK installed
- [ ] Licenses accepted (`flutter doctor --android-licenses`)
- [ ] `flutter doctor` shows no errors (warnings are OK)
- [ ] Project dependencies installed (`flutter pub get`)

Run `flutter doctor` to check your setup!

---

## 💡 Pro Tips

1. **Faster Builds**: Use `flutter build apk --debug` for testing
2. **Smaller APK**: Use `--split-per-abi` flag
3. **Live Testing**: Use `flutter run` to test on connected device
4. **Hot Reload**: Press `r` in terminal while app is running for instant updates

---

## ❓ Common Questions

**Q: How long does the build take?**
A: First build: 10-15 minutes. Subsequent builds: 2-5 minutes.

**Q: How big is the APK?**
A: Release APK: ~45-60 MB. Split APK: ~20-25 MB each.

**Q: Which Android versions are supported?**
A: Android 7.0 (API 24) and above.

**Q: Does the app need internet?**
A: Only once to download ML Kit models. After that, works 100% offline!

**Q: Is my data safe?**
A: YES! No images are stored. All processing is on-device. Zero cloud uploads.

---

## 🆘 Quick Troubleshooting

### "Flutter not recognized"
→ Add Flutter to PATH and restart terminal

### "Android licenses not accepted"
→ Run: `flutter doctor --android-licenses`

### "Gradle build failed"
→ Run: `flutter clean` then rebuild

### "No connected devices"
→ Enable USB debugging on phone, or use emulator

### "Permission denied on app"
→ Go to Settings > Apps > Mood Mirror > Permissions > Allow Camera

---

## 📞 Need Help?

1. Check the main README.md for detailed instructions
2. Run `flutter doctor` to diagnose issues
3. Google the error message
4. Check Flutter documentation: https://docs.flutter.dev

---

**Happy Building! 🎉**
