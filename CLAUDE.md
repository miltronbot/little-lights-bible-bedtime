# Little Lights Bible Bedtime — iOS App

> **⚡ INCOMING CLAUDE: Read `HANDOFF.md` first for full session history, all fixes applied, architecture deep-dive, and debugging commands. This file is the quick-reference summary.**

---

## Project Overview
A free SwiftUI children's Bible bedtime story app for iOS 17+. Features 50 fully-narrated Bible stories, rich procedural artwork, bedtime routine tools, reading streaks, and collectibles. Completely free — no paywall, no ads, no analytics. COPPA compliant.

**Current status: ✅ Builds clean. Runs on simulator. All known bugs fixed.**

## Tech Stack
- **Language:** Swift 5.0
- **UI Framework:** SwiftUI (iOS 17.0+ deployment target)
- **Architecture:** MVVM
- **Audio:** AVFoundation (AVAudioPlayer) — 50 MP3s bundled in app
- **Persistence:** @AppStorage (UserDefaults)
- **Network:** None — fully offline app
- **Bundle ID:** `com.littlelightsbiblebedtime.app`

## Project Structure
```
App/                          # LittleLightsBibleBedtimeApp.swift — entry point, injects all EnvironmentObjects
Models/                       # Story, AppSettings, ReadingStreak, Collectible
ViewModels/                   # StoryLibrary, AudioPlayer, Favorites, Purchase, ReadingStreak
Views/                        # 15 screens
Views/Components/             # 17 reusable components
Services/                     # AudioPlayback, StoryRepository, SleepTimer, AmbientSound, ElevenLabs, Notification, Purchase
Support/                      # AppTheme.swift, StoryArtwork.swift
Resources/stories.json        # All 50 story records (source of truth)
Resources/Audio/              # 50 MP3 narration files
Resources/Ambient/            # 6 ambient sound MP3s
docs/                         # App Store listing, legal HTML, landing page, screenshots
HANDOFF.md                    # Full technical handoff — READ THIS
```

## Key Facts
- **50 stories, all free** — `isFree: true` on all records in stories.json
- **Artwork:** all 50 stories have single Midjourney PNG illustrations in Assets.xcassets (cropped from 2x2 generation grids to one panel each); programmatic painted-scene artwork remains as fallback for any story without an image
- **Audio:** All 50 MP3s are bundled (not streamed). `AVAudioSession` configured as `.playback, mode: .spokenAudio` at startup AND inside each `loadAudio` call
- **ElevenLabs TTS** is an optional fallback — user must add their own API key in Settings → Voice Narration
- **Lumi** — firefly mascot character used throughout the app
- **v1.1 features:** per-child profiles (up to 4, own streak/favorites/collectibles via `ProfileScope` keys), Tonight's Queue (chain up to 3 stories), story-specific `talkAboutIt` questions in stories.json, memory-verse practice game (`MemoryVerseGameView`), tap-the-artwork sparkles (`MagicTouchLayer`, detail view only), completion celebration on narration finish
- **Copy rule:** never use "hiding/hid God's Word in your heart" phrasing in kid-facing strings (owner preference) — say "missing word" / "learning by heart"

## Environment Objects (all injected at app root, available everywhere)
```swift
StoryLibraryViewModel    // story loading, filtering, "Tonight's Story"
AudioPlayerViewModel     // playback, sleep timer, ambient sound
FavoritesViewModel       // favorite story IDs
PurchaseViewModel        // StoreKit 2 (all free, scaffolding only)
ReadingStreakViewModel   // streak days, badges, Sleep Stars
AppSettings              // isBedtimeMode, fontSize, childrenNames, etc.
CollectiblesManager      // collectible item tracking per story
```

## Build & Run
```bash
# Build
bash -c 'cd "/Users/lanesinclair/Downloads/LittleLightsBibleBedtime" && xcodebuild -scheme LittleLightsBibleBedtime -destination "platform=iOS Simulator,name=iPhone 17" -configuration Debug build 2>&1 | tail -3'

# Install + launch
APP=$(find ~/Library/Developer/Xcode/DerivedData -name "LittleLightsBibleBedtime.app" -path "*/Debug-iphonesimulator/*" | grep -v Index | head -1)
xcrun simctl install "iPhone 17" "$APP"
xcrun simctl launch "iPhone 17" com.littlelightsbiblebedtime.app

# Skip onboarding on fresh install
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app hasCompletedOnboarding -bool YES
```

## Critical Rules — Don't Break These

### Audio
`setCategory(.playback, mode: .spokenAudio)` + `setActive(true)` must be called inside BOTH `loadAudio(named:)` AND `loadAudio(from:)` in `AudioPlaybackService.swift` as a non-fatal do-catch. Also called at startup in `configureAudioSession()`. Never add `.mixWithOthers`. Never remove `setCategory` from the load methods.

### Artwork Hit Testing
Every decorative layer inside `StoryArtworkView.swift` must have `.allowsHitTesting(false)`. The ZStack itself uses `.contentShape(RoundedRectangle(cornerRadius:))`. This ensures NavigationLinks wrapping story cards receive taps correctly.

### Environment Objects
All 7 EnvironmentObjects are injected at app root. `StoryDetailView` uses all 7. Never use these views outside the full environment chain.

## Adding Content
- **New story:** Add entry to `Resources/stories.json` + MP3 to `Resources/Audio/` + style in `Support/StoryArtwork.swift`
- **New image:** Add PNG to `Assets.xcassets` with same name as story `id`
- **Theme colors:** Edit `Support/AppTheme.swift`
- **Legal docs:** Edit `docs/privacy-policy.html` and `docs/terms-of-use.html`

## App Store Submission
All materials ready — see `APP_STORE_GUIDE.md` and `docs/GoLiveChecklist.md`.
Done: signing team (ANY3QHU2YX, automatic), privacy manifest (`PrivacyInfo.xcprivacy`), iPhone+iPad device family, screenshots at ASC sizes in `~/Desktop/AppStoreScreenshots/`, privacy policy hosted at https://miltronbot.github.io/little-lights-bible-bedtime/privacy-policy.html
Remaining (needs owner's Apple ID): sign into Xcode (Settings → Accounts), create App Store Connect record, archive & upload, submit for review.

## Owner
**Project Owner** — work autonomously, fix bugs proactively, keep everything free and legal, no shortcuts.

---

*See `HANDOFF.md` for complete session history, all bugs fixed, detailed architecture notes, and debugging commands.*
