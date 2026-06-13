# FireFly: Bible Bedtime Stories — iOS App

> **⚡ INCOMING CLAUDE: Read `HANDOFF.md` first for full session history, all fixes applied, architecture deep-dive, and debugging commands. This file is the quick-reference summary.**

---

## Project Overview
A free SwiftUI children's Bible bedtime story app for iOS 17+. Features 50 fully-narrated Bible stories, rich procedural artwork, bedtime routine tools, reading streaks, and collectibles. Completely free — no paywall, no ads, no analytics. COPPA compliant.

**Current status: v2.0 feature-complete on main (zero warnings); v1.0 in App Store review. ASC name set ("FireFly: Bible Bedtime Stories", owner-confirmed June 2026); Home bobbing confirmed FIXED; 2.0 listing copy AND screenshots both refreshed June 2026 (`~/Desktop/AppStoreCopy/` + `~/Desktop/AppStoreScreenshots/`). All prep is done — remaining 2.0 steps are owner-only ASC actions (paste copy, upload screenshots, archive+upload build). See HANDOFF ⭐ START HERE.**

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
- **Rewards:** 50 collectibles — one per story (`Collectible.all`, Noah gets the Dove not a rainbow) — and 30 badges (`ReadingStreak.badgeInfo`: 12 story-count, 10 streak, 3 Sleep Star, 2 moment, 3 completion rewards — Treasure Keeper for all 50 collectibles, Badge Champion for all 27 core badges, Lumi's Grand Light for both; awarded via `refreshCompletionBadges` after story completion). Icons are procedural SF Symbol compositions (`Support/RewardIcons.swift` — `CollectibleIconView` gem discs, `BadgeIconView` seal medals, specs in `RewardIconCatalog`; emoji fields remain as runtime fallback only — new rewards need a catalog entry). Tap any collectible → Collection Book (`CollectionAlbumView`, all 50 browsable); tap any badge → detail sheet with live progress bar (`BadgeDetailSheet`, targets mirror `checkBadges()` thresholds — keep them in sync)
- **Copy rules:** never use "hiding/hid God's Word in your heart" phrasing (say "missing word" / "learning by heart"); never use the word "Affirmations" (say "Blessings") — both owner preferences
- **v2.0 features:** lock-screen player (`MPNowPlayingInfoCenter`/`MPRemoteCommandCenter` + interruption auto-resume in AudioPlayerViewModel), Lights Out mode (`LightsOutView`, full-screen cover; Kid Lock setting = 3s-hold wake), iCloud progress sync (`CloudSyncService`, KVS + `Firefly.entitlements`), Siri "Play tonight's story" (`FireflyAppIntents`), side menu (`SideMenuView` — themes + quick links, the extension point for new features), wandering Lumi (`WanderingLumiView` on story detail), app-wide Wise Men starry sky, kid pass (card instant-play buttons, completion stars, NO autoplay (removed June 2026 — narration starts only on tap), pulsing Read to Me), Breathe with Lumi, Sleepy Speed (0.85x), Verse of the Day (`VerseOfTheDayCard`), shareable story postcards (`PostcardRenderer`), 7-Day Journeys (`JourneysView` via side menu — 4 themed week plans over existing stories, per-child progress in `JourneyProgressManager`, iCloud union-merged), Wind-Down auto mode (`WindDownService` + Settings toggle — opening at/after bedtime dims into bedtime mode and stages Tonight's Story, never auto-plays), Parent Voice (`VoiceRecordingService`/`ParentVoiceSheet` — per-child recordings replace bundled narration via the `loadStory` chokepoint; mic capture is device-only, sim can't record), Night Sky sticker palette (100 kid-safe stickers — drop-down grid via "All 100 stickers"; first 8 ids frozen for saved skies — plus camera button that saves the child's sky to Photos via add-only permission), Games tab (`GamesView` + `BibleGames.swift` + `GameContent.swift`: 7 games — Story Quiz/Who Am I?/Lumi's True or False/Guess the Story/Treasure Match/Story Scramble/Verse Builder + Verse Practice door — shared game-star currency in `games.totalStars`; every game has 50+ versions: banks cover all 50 stories (quiz & T/F 6 items per story = 300 each; riddle/scramble/builder-verse 1 per story = 50 each) and rounds are dealt via `GameDeck` (persisted no-repeat deck — the next round never repeats the one just played); Favorites tab moved to the side menu to keep 5 tabs)
- **Watch out:** full-screen covers trigger StoryDetailView.onDisappear — the stop-on-leave call is guarded by `showLightsOut`/`showAffirmations`; keep new covers in that guard. Buttons must NOT be nested inside NavigationLink labels (gesture deadlock — see StoryCardView structure). NEVER `withAnimation(.repeatForever)` in onAppear/task — it leaks into screen layout and the whole page bobs (HANDOFF gotcha #9); always scope loops with `.animation(_, value:)`

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
`setCategory(.playback, mode: .default)` + `setActive(true)` must be called inside BOTH `loadAudio(named:)` AND `loadAudio(from:)` in `AudioPlaybackService.swift` as non-fatal `try?`. Also called at startup in `configureAudioSession()`. Never add `.mixWithOthers`. Never remove `setCategory` from the load methods. (Mode is `.default`, verified working — an earlier version of this doc said `.spokenAudio`, which was never what shipped.)

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
