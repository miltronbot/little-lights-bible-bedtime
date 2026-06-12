
# Firefly Bible Bedtime for Kids

A SwiftUI iOS app featuring 50 Bible bedtime stories with audio narration, bedtime reading mode, and a one-time premium unlock via StoreKit 2.

## Included
- Xcode project: `LittleLightsBibleBedtime.xcodeproj`
- SwiftUI source files (MVVM architecture)
- `stories.json` with all 50 stories (8 free, 42 premium)
- 50 narration MP3 assets in `Resources/Audio/`
- StoreKit 2 in-app purchase integration (non-consumable)
- StoreKit configuration file for local testing
- Privacy Policy and Terms markdown files
- App Store submission guide (`APP_STORE_GUIDE.md`)

## Features
- 50 Bible bedtime stories covering Old and New Testament
- Audio narration for every story with background playback support
- Bedtime Mode for comfortable nighttime reading
- Favorites system with persistence
- Search and filter by theme (Trust, Courage, Peace, Love, Hope, Prayer, Kindness)
- Takeaway and bedtime prayer with every story
- One-time premium unlock ($4.99) via StoreKit 2
- No ads, no subscriptions, no data collection

## Getting Started
1. Open `LittleLightsBibleBedtime.xcodeproj` in Xcode
2. Set your Team in Signing & Capabilities
3. Build to simulator or real iPhone (Cmd+R)
4. For IAP testing: set StoreKit Configuration to `Products.storekit` in scheme options

## Next Steps
- Replace placeholder artwork with stock illustrations
- Create app icon (1024x1024 PNG)
- Consider professional voiceover for audio narration
- Enroll in Apple Developer Program and follow `APP_STORE_GUIDE.md`
