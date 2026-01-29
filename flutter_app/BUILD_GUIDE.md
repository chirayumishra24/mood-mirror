# 🎯 How to Build Mood Mirror APK - Complete Guide

## 📋 What You'll Get

By following this guide, you'll create a **ready-to-install Android APK** file for the Mood Mirror app that can run on any Android phone (version 7.0+).

---

## ⏱️ Time Estimate

- **First-time setup**: 30-45 minutes
- **Building APK**: 10-15 minutes
- **Total**: ~1 hour for first build
- **Subsequent builds**: ~5 minutes

---

## 🛠️ Prerequisites Installation

### 1. Install Flutter (Required)

**Windows:**

1. **Download Flutter SDK**
   - Go to: https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable release (ZIP file)
   - Extract to: `C:\flutter` (recommended)

2. **Add Flutter to PATH**
   - Press `Win + X` → System → Advanced system settings
   - Click "Environment Variables"
   - Under "System variables", find and edit "Path"
   - Click "New" and add: `C:\flutter\bin`
   - Click OK on all dialogs

3. **Verify Installation**
   ```powershell
   # Open new PowerShell window
   flutter --version
   ```

### 2. Install Android SDK (Required)

**Option A: Android Studio (Recommended)**

1. **Download Android Studio**
   - Go to: https://developer.android.com/studio
   - Download and install (takes ~10 minutes)

2. **Install Android SDK**
   - Open Android Studio
   - Go to: Tools → SDK Manager
   - Select "SDK Platforms" tab
   - Check: Android 14.0 (API 34)
   - Select "SDK Tools" tab
   - Check: Android SDK Build-Tools, Android SDK Command-line Tools
   - Click "Apply" to install

3. **Accept Android Licenses**
   ```powershell
   flutter doctor --android-licenses
   # Type 'y' for all prompts
   ```

**Option B: Command Line Tools Only (Smaller install)**

1. Download: https://developer.android.com/studio#command-tools
2. Extract to: `C:\Android\cmdline-tools`
3. Add to PATH: `C:\Android\cmdline-tools\bin`
4. Run: `flutter doctor --android-licenses`

### 3. Verify Complete Setup

```powershell
flutter doctor
```

**Expected Output:**
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Android toolchain - develop for Android devices
[✓] Android Studio (version 2023.x)
[!] Optional warnings are OK
```

---

## 🚀 Building the APK

### Step 1: Open Project Directory

```powershell
cd "C:\Users\saini\Documents\SkilliZee\MoodMirror\mood-mirror-1\flutter_app"
```

### Step 2: Install Dependencies

```powershell
# Download all required packages
flutter pub get
```

**This will install:**
- Camera plugin
- ML Kit for face detection
- Text-to-speech
- Permission handler
- Other dependencies

### Step 3: Build Release APK

```powershell
# Build optimized APK for production
flutter build apk --release
```

**What happens during build:**
1. Compiles Dart code to native ARM code
2. Bundles all assets and dependencies
3. Optimizes and minifies code
4. Signs APK with debug key
5. Creates final APK file

**Build time:**
- First build: 10-15 minutes ☕
- Subsequent builds: 2-5 minutes

### Alternative: Use Automated Script

```powershell
# Run the automated build script
.\build_apk.ps1
```

This script will:
- Check Flutter installation
- Run flutter doctor
- Clean previous builds
- Install dependencies
- Build release APK
- Open output folder automatically

---

## 📦 Locating Your APK

After successful build, your APK is located at:

```
flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

**Full path:**
```
C:\Users\saini\Documents\SkilliZee\MoodMirror\mood-mirror-1\flutter_app\build\app\outputs\flutter-apk\app-release.apk
```

**File details:**
- **Size**: ~45-60 MB
- **Name**: `app-release.apk`
- **Type**: Android Application Package

---

## 📱 Installing APK on Android Phone

### Method 1: Direct Transfer (Easiest)

1. **Copy APK to phone**
   - Connect phone to PC via USB
   - Copy `app-release.apk` to phone's Download folder
   - Or use Google Drive / WhatsApp to transfer

2. **Install on phone**
   - Open "Files" or "Downloads" app on phone
   - Tap on `app-release.apk`
   - If prompted, allow "Install from Unknown Sources"
     - Settings → Security → Unknown Sources → Enable
   - Tap "Install"
   - Wait for installation (~30 seconds)

3. **Grant permissions**
   - Open "Mood Mirror" app
   - Allow Camera permission when prompted
   - Start using the app!

### Method 2: Via USB Debugging (Advanced)

1. **Enable Developer Options on phone**
   - Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer Options now enabled

2. **Enable USB Debugging**
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Connect and Install**
   ```powershell
   # Check if device is connected
   adb devices
   
   # Install APK
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

### Method 3: Run Directly from Flutter

```powershell
# Connect phone via USB with debugging enabled
flutter devices

# Install and run
flutter install
```

---

## 🎯 Testing Your App

### First Launch:

1. **Grant Camera Permission**
   - Tap "Allow" when prompted
   - If denied, go to: Settings → Apps → Mood Mirror → Permissions → Camera

2. **Read Disclaimer**
   - First launch shows educational disclaimer
   - Tap "I Understand - Let's Start!"

3. **Test Emotion Detection**
   - Camera will show your face
   - Wait 2 seconds for detection
   - See your detected emotion with emoji
   - Listen to voice feedback (optional)

4. **Try Different Emotions**
   - Smile → Happy 😊
   - Frown → Sad 😢
   - Neutral face → Calm 😐
   - Wide eyes → Surprised 😲

---

## 🎨 Customization (Optional)

### Change App Name:

**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<application
    android:label="Your Custom Name"
    ...>
```

### Change Package ID:

**File**: `android/app/build.gradle`
```gradle
defaultConfig {
    applicationId "com.yourcompany.yourapp"
    ...
}
```

### Add Custom Icon:

1. Create 1024x1024 PNG icon
2. Use: https://romannurik.github.io/AndroidAssetStudio/icons-launcher.html
3. Download generated icons
4. Replace icons in: `android/app/src/main/res/mipmap-*/`

### Modify Emotions/Jokes:

**File**: `lib/models/emotion_data.dart`
- Edit `emotions` map for mood messages
- Edit `jokes` list for different jokes
- Edit `suggestions` map for custom suggestions

---

## 🐛 Troubleshooting

### Problem: "flutter: command not found"

**Solution:**
```powershell
# Verify PATH includes Flutter
$env:PATH

# If missing, add Flutter to PATH:
# System → Advanced → Environment Variables → Path → New
# Add: C:\flutter\bin

# Restart PowerShell
```

### Problem: "Android license status unknown"

**Solution:**
```powershell
flutter doctor --android-licenses
# Type 'y' for all prompts
```

### Problem: "No connected devices"

**Solution:**
- Enable USB Debugging on phone
- Check USB cable connection
- Run: `adb devices` to verify
- Or use APK transfer method instead

### Problem: "Gradle build failed"

**Solution:**
```powershell
# Clean project
flutter clean

# Clear Gradle cache
cd android
.\gradlew clean
cd ..

# Rebuild
flutter pub get
flutter build apk --release
```

### Problem: "Could not find SDK"

**Solution:**
1. Open Android Studio
2. Tools → SDK Manager
3. Ensure Android SDK is installed
4. Note SDK location (e.g., `C:\Users\YourName\AppData\Local\Android\Sdk`)
5. Create `local.properties` in `android/` folder:
   ```
   sdk.dir=C:\\Users\\YourName\\AppData\\Local\\Android\\Sdk
   ```

### Problem: App crashes on launch

**Solution:**
- Ensure Android version is 7.0+
- Check phone has Google Play Services (required for ML Kit)
- Grant camera permission in Settings

### Problem: Emotion detection not working

**Solution:**
- Ensure good lighting
- Face the camera directly
- Grant camera permission
- First launch requires internet (to download ML models)
- Check if phone has front camera

---

## 📊 Build Optimization

### Smaller APK (Split by CPU architecture):

```powershell
flutter build apk --split-per-abi --release
```

**Creates 3 APKs:**
- `app-armeabi-v7a-release.apk` (~20 MB) - 32-bit ARM
- `app-arm64-v8a-release.apk` (~22 MB) - 64-bit ARM (most modern phones)
- `app-x86_64-release.apk` (~25 MB) - Intel processors

**Use the arm64-v8a version for most modern phones!**

### App Bundle (For Play Store):

```powershell
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

---

## ✅ Build Checklist

Before building, ensure:

- [ ] Flutter installed and in PATH
- [ ] Android SDK installed
- [ ] Licenses accepted (`flutter doctor --android-licenses`)
- [ ] `flutter doctor` shows checkmarks for Flutter and Android
- [ ] Project dependencies installed (`flutter pub get`)
- [ ] No syntax errors in code
- [ ] Permissions configured in AndroidManifest.xml
- [ ] Package name is unique (if publishing)

---

## 🎓 For School Exhibitions

### Presentation Tips:

1. **Demo the app**
   - Show live emotion detection
   - Demonstrate different emotions
   - Explain the disclaimer

2. **Explain the technology**
   - Flutter for cross-platform development
   - ML Kit for on-device AI
   - Privacy-first design (no data storage)

3. **Show the code**
   - Open `lib/main.dart` to show UI code
   - Explain emotion detection logic
   - Demonstrate Flutter hot reload

4. **APK Distribution**
   - Share APK via Google Drive link
   - Or use QR code generator for APK download
   - Or AirDroid for wireless transfer

---

## 📈 Performance Stats

| Metric | Value |
|--------|-------|
| APK Size | 45-60 MB (release) |
| APK Size | 20-25 MB (split per ABI) |
| Cold Start Time | 2-3 seconds |
| Emotion Detection | ~2 seconds |
| RAM Usage | 150-200 MB |
| Min Android Version | 7.0 (API 24) |
| Target Android | 14 (API 34) |

---

## 🎉 Success Criteria

You've successfully built the APK if:

- ✅ `flutter build apk --release` completes without errors
- ✅ `app-release.apk` file exists in outputs folder
- ✅ APK installs on Android phone
- ✅ App launches without crashing
- ✅ Camera permission can be granted
- ✅ Emotions are detected and displayed
- ✅ Voice feedback works (optional)

---

## 📞 Getting Help

1. **Check Flutter Doctor**
   ```powershell
   flutter doctor -v
   ```

2. **Check Build Logs**
   - Look for errors in terminal output
   - Common issues: SDK not found, licenses not accepted

3. **Online Resources**
   - Flutter Docs: https://docs.flutter.dev
   - Flutter Discord: https://discord.gg/flutter
   - Stack Overflow: Search for error messages

4. **Project Files**
   - Read: `README.md` for full documentation
   - Read: `QUICK_START.md` for quick setup
   - Read: `PROJECT_INFO.md` for project details

---

## 🎯 Next Steps After Building

1. **Test thoroughly** on multiple devices
2. **Share APK** with friends and family
3. **Demo at exhibition** with confidence
4. **Customize** jokes and UI to your liking
5. **Learn Flutter** to build more apps!
6. **Add features** like:
   - More emotions
   - Photo capture
   - Mood history (with privacy)
   - Different themes
   - Multiple languages

---

## 🏆 Achievement Unlocked!

Congratulations! You've successfully built your first Flutter Android app! 🎉

You now know how to:
- ✅ Set up Flutter development environment
- ✅ Build Android APKs from Flutter code
- ✅ Integrate ML Kit for on-device AI
- ✅ Handle camera permissions
- ✅ Create parent-friendly UIs
- ✅ Distribute apps via APK

**Keep building and learning! 🚀**

---

**Happy Building! 😊**

*This guide was created for educational purposes. Use responsibly and have fun!*
