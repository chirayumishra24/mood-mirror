# 🪞 Mood Mirror - Android App

An AI-based emotion reflection app that uses your phone's front camera to analyze facial expressions and identify basic emotions.

## 📱 Features

✅ **Real-time Emotion Detection**
- Detects: Happy 😊, Sad 😢, Angry 😠, Calm 😐, Surprised 😲
- Uses Google ML Kit for on-device face detection
- Live camera preview with instant feedback

✅ **Privacy First**
- ✓ No images or videos stored
- ✓ All processing happens on device
- ✓ No cloud uploads
- ✓ Educational purposes only

✅ **Fun & Friendly**
- Emoji-based mood display
- Random jokes to brighten your day
- Helpful suggestions for negative moods
- Text-to-speech voice feedback

✅ **Parent & Child Friendly**
- Large, easy-to-read text and emojis
- Simple one-screen design
- Bright, colorful UI
- Safe and appropriate content

## 🛠️ Technical Stack

- **Framework**: Flutter 3.x
- **ML Engine**: Google ML Kit Face Detection
- **Camera**: Flutter Camera Plugin
- **Voice**: Flutter TTS (Text-to-Speech)
- **Target**: Android 7.0+ (API 24+)

## 📋 Prerequisites

Before building the APK, ensure you have:

1. **Flutter SDK** (3.0 or higher)
   - Download from: https://docs.flutter.dev/get-started/install
   
2. **Android Studio** or **Android SDK**
   - Download from: https://developer.android.com/studio
   
3. **Java Development Kit (JDK)** 11 or higher
   - Download from: https://www.oracle.com/java/technologies/downloads/

4. **Git** (optional, for version control)

## 🚀 Building the APK

### Step 1: Set Up Flutter Environment

```powershell
# Verify Flutter installation
flutter doctor

# If Flutter is not installed, download and add to PATH
# Windows: Add Flutter\bin to System Environment Variables
```

### Step 2: Navigate to Project Directory

```powershell
cd "C:\Users\saini\Documents\SkilliZee\MoodMirror\mood-mirror-1\flutter_app"
```

### Step 3: Install Dependencies

```powershell
# Get all Flutter packages
flutter pub get

# Clean previous builds (optional)
flutter clean
```

### Step 4: Build APK

#### Option A: Build Release APK (Recommended)

```powershell
# Build optimized APK for release
flutter build apk --release

# APK will be created at:
# build\app\outputs\flutter-apk\app-release.apk
```

#### Option B: Build Debug APK (For Testing)

```powershell
# Build debug APK
flutter build apk --debug

# APK will be created at:
# build\app\outputs\flutter-apk\app-debug.apk
```

#### Option C: Build Split APKs (Smaller Size)

```powershell
# Build separate APKs for different architectures
flutter build apk --split-per-abi

# Creates 3 APKs:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (Intel 64-bit)
```

### Step 5: Install APK on Android Device

#### Via USB Cable:

```powershell
# Enable USB debugging on your Android phone first
# Settings > Developer Options > USB Debugging

# Install the APK
flutter install

# Or use ADB directly
adb install build\app\outputs\flutter-apk\app-release.apk
```

#### Via File Transfer:

1. Copy the APK file to your phone
2. Open the APK file on your phone
3. Allow installation from unknown sources if prompted
4. Tap "Install"

## 📦 APK Location

After building, find your APK here:

```
flutter_app/
└── build/
    └── app/
        └── outputs/
            └── flutter-apk/
                ├── app-release.apk          (Main release APK)
                ├── app-debug.apk            (Debug version)
                └── app-arm64-v8a-release.apk (Split APK)
```

## 🎯 Testing the App

### On Physical Device (Recommended):

```powershell
# Connect Android phone via USB with debugging enabled
flutter devices

# Run the app
flutter run --release
```

### On Android Emulator:

```powershell
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run the app
flutter run
```

## 🐛 Troubleshooting

### Issue: "Flutter not recognized"
**Solution**: Add Flutter SDK to your system PATH
```powershell
# Add to PATH:
C:\path\to\flutter\bin
```

### Issue: "Android licenses not accepted"
**Solution**: Accept Android SDK licenses
```powershell
flutter doctor --android-licenses
```

### Issue: "Gradle build failed"
**Solution**: Clean and rebuild
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Issue: "Camera permission denied"
**Solution**: The app will prompt for permission. Grant it in Settings > Apps > Mood Mirror > Permissions

### Issue: "ML Kit not working"
**Solution**: Ensure you have Google Play Services on your device. ML Kit requires it for face detection.

## 📱 App Permissions

The app requires:
- **Camera**: To capture facial expressions
- **Internet**: For ML Kit model downloads (one-time only)

## 🎨 App Structure

```
lib/
├── main.dart                      # Main app entry and UI
├── models/
│   └── emotion_data.dart          # Emotion data, jokes, suggestions
└── services/
    └── emotion_detection_service.dart  # ML Kit emotion detection
```

## 🔧 Configuration

### Customize App Name:
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Mood Mirror" ...>
```

### Change App Icon:
Replace icons in:
```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png
├── mipmap-mdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
└── mipmap-xxhdpi/ic_launcher.png
```

### Modify Package Name:
Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.skilliZee.mood_mirror"
    ...
}
```

## 📊 APK Size Optimization

To reduce APK size:

```powershell
# Build with split APKs
flutter build apk --split-per-abi --release

# Enable ProGuard/R8 (already configured)
# Results in ~40% smaller APK
```

Expected APK sizes:
- **Release APK**: ~45-60 MB
- **Split APKs**: ~20-25 MB each

## 🎓 Educational Use

Perfect for:
- School science fairs
- STEM exhibitions
- Parent-child activities
- Learning about AI and emotions
- Mobile app development demonstrations

## ⚠️ Disclaimer

**For Educational and Fun Purposes Only**

This app is NOT:
- A medical diagnostic tool
- A psychological assessment tool
- A substitute for professional mental health care

The emotion detection is approximate and for entertainment purposes.

## 📄 License

This project is created for educational purposes.

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Flutter documentation: https://docs.flutter.dev
3. Check ML Kit documentation: https://developers.google.com/ml-kit

## 📸 Screenshots

(Screenshots will appear once the app is running)

---

**Built with Flutter** 💙 **Powered by ML Kit** 🧠

**App Version**: 1.0.0  
**Min Android**: 7.0 (API 24)  
**Target Android**: 14 (API 34)
