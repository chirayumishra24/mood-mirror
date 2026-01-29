# Mood Mirror - Assets Directory

This directory contains app assets like images, models, and fonts.

## Directory Structure:

```
assets/
├── images/          # App images and icons
├── models/          # ML models (if needed)
└── fonts/           # Custom fonts (optional)
```

## Notes:

- **images/**: Place your app icon source files here
- **models/**: ML Kit downloads models automatically, but you can add custom TFLite models here
- **fonts/**: Add Poppins or other custom fonts if desired (optional, system fonts work too)

## App Icon:

To create a custom app icon:
1. Create a 1024x1024 PNG with a mirror + smile emoji design
2. Use online tools like: https://romannurik.github.io/AndroidAssetStudio/
3. Generate all sizes and replace in: `android/app/src/main/res/mipmap-*/`

The default Flutter icon will work for now!
