# Mood Mirror - Setup Verification Script
# Run this to check if your system is ready to build the APK

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Mood Mirror - Setup Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check 1: Flutter Installation
Write-Host "1. Checking Flutter installation..." -ForegroundColor Yellow
$flutter = Get-Command flutter -ErrorAction SilentlyContinue

if ($flutter) {
    $flutterVersion = flutter --version 2>&1 | Select-String "Flutter" | Select-Object -First 1
    Write-Host "   ✅ Flutter found: $flutterVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Flutter NOT found" -ForegroundColor Red
    Write-Host "      Install from: https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check 2: Java/JDK
Write-Host "2. Checking Java installation..." -ForegroundColor Yellow
$java = Get-Command java -ErrorAction SilentlyContinue

if ($java) {
    $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    Write-Host "   ✅ Java found: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "   ❌ Java NOT found" -ForegroundColor Red
    Write-Host "      Install JDK 11+ from: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check 3: Android SDK
Write-Host "3. Checking Android SDK..." -ForegroundColor Yellow
$androidHome = $env:ANDROID_HOME

if ($androidHome -and (Test-Path $androidHome)) {
    Write-Host "   ✅ Android SDK found at: $androidHome" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  ANDROID_HOME not set" -ForegroundColor Yellow
    Write-Host "      Install Android Studio or set ANDROID_HOME variable" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check 4: Flutter Doctor
if ($flutter) {
    Write-Host "4. Running Flutter Doctor..." -ForegroundColor Yellow
    Write-Host ""
    flutter doctor
    Write-Host ""
}

# Check 5: Project Dependencies
Write-Host "5. Checking project location..." -ForegroundColor Yellow
$pubspecPath = "pubspec.yaml"

if (Test-Path $pubspecPath) {
    Write-Host "   ✅ Project found (pubspec.yaml exists)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "6. Checking dependencies..." -ForegroundColor Yellow
    $pubspecContent = Get-Content $pubspecPath -Raw
    
    $dependencies = @("camera", "google_mlkit_face_detection", "flutter_tts", "permission_handler")
    foreach ($dep in $dependencies) {
        if ($pubspecContent -match $dep) {
            Write-Host "   ✅ $dep configured" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $dep NOT found" -ForegroundColor Red
            $allGood = $false
        }
    }
} else {
    Write-Host "   ❌ pubspec.yaml NOT found" -ForegroundColor Red
    Write-Host "      Make sure you're in the flutter_app directory" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Final verdict
Write-Host "========================================" -ForegroundColor Cyan
if ($allGood) {
    Write-Host "  ✅ SYSTEM READY TO BUILD!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run: flutter pub get" -ForegroundColor White
    Write-Host "  2. Run: flutter build apk --release" -ForegroundColor White
    Write-Host "  3. Or simply run: .\build_apk.ps1" -ForegroundColor White
} else {
    Write-Host "  ⚠️  SETUP INCOMPLETE" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Please fix the issues marked with ❌ above" -ForegroundColor Yellow
    Write-Host "Then run this script again to verify" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Need help? Check these files:" -ForegroundColor Cyan
    Write-Host "  - QUICK_START.md (fast setup)" -ForegroundColor White
    Write-Host "  - BUILD_GUIDE.md (detailed guide)" -ForegroundColor White
}
Write-Host ""

# Useful info
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Quick Reference" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Flutter Commands:" -ForegroundColor Yellow
Write-Host "  flutter doctor              - Check setup" -ForegroundColor White
Write-Host "  flutter pub get             - Install dependencies" -ForegroundColor White
Write-Host "  flutter build apk --release - Build APK" -ForegroundColor White
Write-Host "  flutter clean               - Clean project" -ForegroundColor White
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Yellow
Write-Host "  START_HERE.md    - Project overview" -ForegroundColor White
Write-Host "  QUICK_START.md   - Fast setup (3 steps)" -ForegroundColor White
Write-Host "  BUILD_GUIDE.md   - Complete build guide" -ForegroundColor White
Write-Host "  README.md        - Full documentation" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
