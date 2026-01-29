# Mood Mirror - Quick Build Script
# Run this script to build the Android APK

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Mood Mirror - APK Builder" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterCheck) {
    Write-Host "❌ ERROR: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Flutter from: https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

Write-Host "✅ Flutter found!" -ForegroundColor Green
Write-Host ""

# Run Flutter Doctor
Write-Host "Running Flutter Doctor..." -ForegroundColor Yellow
flutter doctor
Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host "✅ Clean complete!" -ForegroundColor Green
Write-Host ""

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host "✅ Dependencies installed!" -ForegroundColor Green
Write-Host ""

# Build APK
Write-Host "Building Release APK... (This may take 5-10 minutes)" -ForegroundColor Yellow
Write-Host "☕ Grab a coffee while you wait!" -ForegroundColor Cyan
Write-Host ""

flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================" -ForegroundColor Green
    Write-Host "✅ SUCCESS! APK Built!" -ForegroundColor Green
    Write-Host "================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📱 Your APK is ready at:" -ForegroundColor Cyan
    Write-Host "   build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Copy the APK to your Android phone" -ForegroundColor White
    Write-Host "   2. Open the APK file on your phone" -ForegroundColor White
    Write-Host "   3. Allow installation from unknown sources if prompted" -ForegroundColor White
    Write-Host "   4. Tap Install and enjoy! 😊" -ForegroundColor White
    Write-Host ""
    
    # Open the output folder
    $apkPath = "build\app\outputs\flutter-apk"
    if (Test-Path $apkPath) {
        Write-Host "Opening APK folder..." -ForegroundColor Cyan
        explorer.exe $apkPath
    }
} else {
    Write-Host ""
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common solutions:" -ForegroundColor Yellow
    Write-Host "   1. Run: flutter doctor --android-licenses" -ForegroundColor White
    Write-Host "   2. Ensure Android SDK is installed" -ForegroundColor White
    Write-Host "   3. Check the error messages above" -ForegroundColor White
    Write-Host ""
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
