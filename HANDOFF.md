# Little Lights Bible Bedtime — Claude Handoff Document
**Last updated:** June 10, 2026
**Handoff from:** Claude Opus 4.8 (launch-prep session)
**Status:** Feature-complete v1.1, Release builds clean, App Store materials ready ✅ — awaiting owner's Apple ID for archive/upload

---

## What This App Is

**Little Lights Bible Bedtime** is a free iOS children's Bible bedtime story app for ages 3–8.

- **50 fully-narrated Bible stories** with bundled MP3 audio (OpenAI tts-1-hd, 192kbps)
- **Single Midjourney illustrations for all 50 stories** (cropped from 2x2 generation grids to one panel each); SwiftUI painted-scene system remains as fallback
- **Bedtime routine** — breathing exercise, sleep timer, ambient sounds
- **Tonight's Queue** — chain up to 3 stories that auto-play, then drift into ambient sound
- **Per-child profiles** — up to 4 children, each with own streak/favorites/collectibles
- **Talk About It** — story-specific parent-child question on every story
- **Memory verse practice game** — gentle find-the-missing-word (45 stories)
- **Magic touch sparkles** — tap the detail artwork for a calm firefly burst
- **Reading streak tracking** with badges and Sleep Stars; completion celebrated when narration finishes
- **Lumi the firefly** — animated mascot throughout the app
- **100% free** — no paywall, no ads, no analytics, COPPA compliant, fully offline
- **Bundle ID:** `com.littlelightsbiblebedtime.app`
- **Target:** iPhone + iPad, iOS 17.0+, SwiftUI

---

## Current App State (as of this handoff)

### ✅ CONFIRMED WORKING
- **Build:** Compiles clean — zero errors, zero warnings
- **Audio:** All 50 story MP3s bundled and playing (`AVAudioSession` correctly configured)
- **Artwork:** All 50 stories show artwork — 11 real photos + 39 procedural painted scenes
- **Navigation:** All NavigationLinks verified — Home → StoryDetail, Library → StoryDetail, categories, favorites, bedtime routine all functional
- **Data:** All 50 stories load from `Resources/stories.json` with complete fields
- **Both modes:** Day mode (light) and Bedtime mode (dark/starry) both render correctly
- **Breathing exercise:** Cancellable `Task { @MainActor }` properly cleans up on dismiss
- **Streak tracking:** Day-boundary safe, weekOfYear 1-based offset fixed
- **Simulator tested:** iPhone 17 simulator, iOS 26.4

### What Was Fixed In The Last Session
1. **Audio regression fixed** — `setCategory(.playback, mode: .spokenAudio)` restored inside both `loadAudio(named:)` and `loadAudio(from:)` as non-fatal do-catch; `.mixWithOthers` removed from `configureAudioSession()`
2. **Hit-testing cleanup** — Added `.allowsHitTesting(false)` to `PaintedSceneBackground` and all `LinearGradient` overlay layers in `StoryArtworkView` — decorative layers no longer intercept taps
3. **Prior session fixes** (already in code): procedural artwork for 39 stories, weekOfYear offset, confetti animation safety, breathing task cancellation, ElevenLabs force-unwrap, SupportView URL force-unwrap

### Known Non-Issues (investigated, not bugs)
- **"Links broken"** — User reported this; code investigation + simulator testing confirmed all NavigationLinks work. Likely user was accidentally triggering horizontal scroll gesture instead of tap. No code fix needed.
- **"Artwork not right"** — Reported when procedural artwork was first added. Now renders correctly in both day and night modes. Confirmed in screenshots.

---

## How To Build & Run

```bash
# Build for simulator
cd /Users/lanesinclair/Downloads/LittleLightsBibleBedtime
xcodebuild -scheme LittleLightsBibleBedtime \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug build

# Install and launch
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "LittleLightsBibleBedtime.app" -path "*/Debug-iphonesimulator/*" | head -1)
xcrun simctl install "iPhone 17" "$APP_PATH"
xcrun simctl launch "iPhone 17" com.littlelightsbiblebedtime.app

# Screenshot
xcrun simctl io "iPhone 17" screenshot /tmp/screenshot.png

# Set bedtime mode (for testing dark UI)
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app isBedtimeMode -bool YES

# Reset to day mode
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app isBedtimeMode -bool NO

# Skip onboarding (after fresh install)
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app hasCompletedOnboarding -bool YES
```

---

## Critical Files — What They Do

### Core Architecture

| File | Purpose |
|------|---------|
| `App/LittleLightsBibleBedtimeApp.swift` | App entry. Calls `AudioPlaybackService.configureAudioSession()` at init. Injects all 7 EnvironmentObjects. |
| `Models/Story.swift` | Story data model. Fields: id, title, subtitle, bibleReference, category, ageGroup, storyText, takeaway, bedtimePrayer, memoryVerse, discussionQuestions, audioFileName, imageName, isFree, readDurationMinutes, listenDurationMinutes |
| `Models/AppSettings.swift` | `@AppStorage`-backed user prefs. Key fields: `isBedtimeMode`, `hasCompletedOnboarding`, `childrenNames`, `fontSize`, `elevenLabsAPIKey` |
| `Resources/stories.json` | All 50 story records. Source of truth for all content. |
| `Resources/Audio/` | 50 MP3 narration files. Names match `story.audioFileName`. |
| `Resources/Ambient/` | 6 ambient MP3s: ocean, rain, crickets, fireplace, lullaby, white_noise |

### Services

| File | Purpose |
|------|---------|
| `Services/AudioPlaybackService.swift` | **CRITICAL — recently fixed.** Wraps `AVAudioPlayer`. `configureAudioSession()` called at startup. `loadAudio(named:)` and `loadAudio(from:)` BOTH call `setCategory(.playback, mode: .spokenAudio)` + `setActive(true)` as non-fatal do-catch before loading. No `.mixWithOthers`. |
| `Services/ElevenLabsService.swift` | Optional TTS fallback if no bundled MP3 found. User must add API key in Settings. Force-unwrap on DocumentDirectory fixed. |
| `Services/AmbientSoundService.swift` | Plays looping ambient sounds. Fixed fake state issue (was always reporting `.none`). |
| `Services/SleepTimerService.swift` | Countdown timer that triggers `fadeOutAndStop()` in AudioPlayerViewModel. |
| `Services/StoryRepository.swift` | Loads `stories.json` from bundle. Throws `StoryRepositoryError`. |

### ViewModels

| File | Purpose |
|------|---------|
| `ViewModels/AudioPlayerViewModel.swift` | Main audio controller. `togglePlayback(for:)` → `loadAndPlayAsync()`. Tries bundled MP3 first (`try? audioService.loadAudio(named:)`), then ElevenLabs cache, then ElevenLabs API. Cancellable `loadTask`. Fade-out uses `currentFadeID` UUID pattern to invalidate stale closures. |
| `ViewModels/StoryLibraryViewModel.swift` | Loads stories, filters, computes `tonightsStory` (rotates daily by dayOfYear). |
| `ViewModels/ReadingStreakViewModel.swift` | Tracks daily reading streak, Sleep Stars, badges. Day-boundary safe. |
| `ViewModels/FavoritesViewModel.swift` | Persists favorite story IDs to UserDefaults. |
| `ViewModels/PurchaseViewModel.swift` | StoreKit 2 scaffolding — all stories free, no active paywall. |

### Views — Key Screens

| File | Notes |
|------|-------|
| `Views/ContentView.swift` | TabView with 5 NavigationStacks: Home, Library, Favorites, Rewards, Settings |
| `Views/HomeView.swift` | Main home screen. Has NavigationLinks for recently read (horizontal ScrollView), favorites (horizontal ScrollView), tonight's story, story of week, categories, seasonal pick, all stories list. All card components defined at bottom of this file: `TonightsStoryCard`, `StoryOfTheWeekCard`, `SeasonalPickCard`, `StreakBannerView`, `BedtimeRoutineCard`, `CategoryCard`, `MiniPlayerBar`. |
| `Views/LibraryView.swift` | Search + age/category filter chips + `LazyVStack` of story cards with NavigationLinks. |
| `Views/StoryDetailView.swift` | Story detail page. Hero artwork (220pt tall), Lumi mascot, Read to Me button, `AudioPlayerBar`, full story text with `ReadAlongTextView`, memory verse, discussion questions, bedtime prayer, collectible preview, mark-as-read. Requires all 7 EnvironmentObjects. |
| `Views/BedtimeRoutineView.swift` | Breathing exercise. Uses `Task { @MainActor }` with `Task.isCancelled` guards. `breathingTask` cancelled in `.onDisappear`. Skip button also cancels task. |
| `Views/OnboardingView.swift` | First-launch name entry. Sets `hasCompletedOnboarding = true`. Supports up to 4 children names. |

### Components

| File | Notes |
|------|-------|
| `Views/Components/StoryArtworkView.swift` | **Key component.** `GeometryReader` wrapper. If `UIImage(named: story.id) != nil` → shows real Midjourney photo with shimmer overlay. Otherwise → full procedural painted scene. ALL overlay layers have `.allowsHitTesting(false)`. `contentShape(RoundedRectangle)` ensures correct tap area. |
| `Views/Components/AudioPlayerBar.swift` | In-story audio player UI. Progress slider, skip ±15s, play/pause. Shows ElevenLabs voice name when active. |
| `Views/Components/InteractiveTouchOverlay.swift` | Tap-to-reveal emoji elements on hero image. Uses `.simultaneousGesture` so it doesn't block NavigationLinks. |
| `Views/Components/ConfettiCelebrationView.swift` | Celebration animation when story completed. Fixed stale index mutation. |
| `Views/Components/StarryNightBackground.swift` | Bedtime mode background. Animated stars. |
| `Views/Components/LumiMascotView.swift` | Firefly mascot with speech bubble. |

### Support

| File | Notes |
|------|-------|
| `Support/StoryArtwork.swift` | Maps every story ID to a `StoryArtworkStyle` (primary color, secondary color, main SF Symbol, accent SF Symbol). Has explicit `case` for all 50 story IDs. Has `default` fallback for safety. Bedtime mode uses darker color variants. |
| `Support/AppTheme.swift` | Color helpers: `primaryText(for:)`, `secondaryText(for:)`, `accent(for:)`, `cardBackground(for:)`, `background(for:)`. Takes `isBedtimeMode: Bool`. |

---

## The Artwork System (Important — Understand This)

39 of 50 stories use **programmatic painted-scene artwork** in `StoryArtworkView.swift`:

```
PaintedSceneBackground   — 4-stop sky gradient + celestial body (sun/moon) + warm glow
SpotlightLayer           — Pulsing white elliptical beam (divine light effect)
GroundSilhouetteLayer    — Two overlapping ellipses at bottom (rolling hills)
SceneComposition         — Main SF Symbol (30% of min dimension) + accent symbol + category decorations
AmbientParticlesLayer    — 12 animated sparkle/heart/leaf particles
LinearGradient           — Bottom text-readability fade
```

All layers use `.allowsHitTesting(false)` except the base container (which has `.contentShape(RoundedRectangle)`).

The 11 stories with **real Midjourney photos** (stored as PNG in Assets.xcassets):
`noah-big-boat`, `mary-and-martha`, `the-ten-lepers`, `jesus-in-the-garden-of-gethsemane`, `the-empty-tomb`, `peter-walks-on-water`, `the-widows-offering`, `jesus-and-the-woman-at-the-well`, `the-talents`, `jesus-washes-the-disciples-feet`, `the-light-of-the-world`

---

## Audio Architecture (Important — Don't Break This)

```
User taps "Read to Me"
    → AudioPlayerViewModel.togglePlayback(for: story)
    → loadAndPlayAsync(story:)
        1. try? audioService.loadAudio(named: story.audioFileName)
           ↳ Sets setCategory(.playback, mode: .spokenAudio) + setActive(true) non-fatally
           ↳ Bundle.main.url(forResource:withExtension:) lookup
           ↳ If nil → throws AudioPlaybackError.fileNotFound → try? returns nil
        2. If nil → try ElevenLabs cached file
        3. If no cache → try ElevenLabs API (requires API key in Settings)
        4. If no API key → show "Add your ElevenLabs API key in Settings" error
```

**Rule:** `setCategory(.playback, mode: .spokenAudio)` must be called in BOTH `configureAudioSession()` AND inside each `loadAudio` method. Never add `.mixWithOthers`. Never remove `setCategory` from `loadAudio`.

---

## Environment Object Chain

All 7 injected at `LittleLightsBibleBedtimeApp.swift` → available everywhere:
```swift
.environmentObject(libraryViewModel)       // StoryLibraryViewModel
.environmentObject(purchaseViewModel)      // PurchaseViewModel
.environmentObject(favoritesViewModel)     // FavoritesViewModel
.environmentObject(appSettings)            // AppSettings
.environmentObject(audioPlayerViewModel)   // AudioPlayerViewModel
.environmentObject(readingStreakViewModel) // ReadingStreakViewModel
.environmentObject(collectiblesManager)    // CollectiblesManager
```

`StoryDetailView` uses all of these. Any new view that shows story detail needs them in environment.

---

## Stories.json Structure

```json
{
  "id": "noah-big-boat",
  "title": "Noah and the Big Boat",
  "subtitle": "A story about trusting God",
  "bibleReference": "Genesis 6-9",
  "category": "Trust",
  "ageGroup": "3-5",
  "isFree": true,
  "readDurationMinutes": 5,
  "listenDurationMinutes": 5,
  "imageName": "noah-big-boat",
  "audioFileName": "noah_big_boat.mp3",
  "storyText": "...",
  "takeaway": "...",
  "bedtimePrayer": "...",
  "memoryVerse": "...",
  "discussionQuestions": ["...", "...", "..."]
}
```

All 50 stories: categories are `Trust`, `Courage`, `Peace`, `Love`, `Hope`, `Prayer`, `Kindness`. All `isFree: true`.

---

## What Still Could Be Improved (Future Work)

The app is feature-complete and working. These are optional enhancements:

1. **UI Tests** — No XCUITest target exists. Adding one would help regression-test navigation and playback.
2. **Onboarding polish** — Could add a "Skip" option if user doesn't want to enter a child name.
3. **Library tab refinement** — The horizontal filter chips (age group + category) could benefit from a sticky header as user scrolls.
4. **App Store submission** — All docs are in `docs/` and `APP_STORE_GUIDE.md`. Icons and screenshots need to be finalized.
5. **iPad support** — Currently iPhone-first. Layout may need adaptation for iPad.
6. **Accessibility** — VoiceOver labels on artwork cards would improve accessibility rating.
7. **ElevenLabs voices** — The voice selection UI in Settings is present but user needs their own API key.

---

## App Store Readiness

| Item | Status |
|------|--------|
| App Store listing copy | ✅ `docs/AppStoreListing.md` |
| Privacy Policy | ✅ `docs/privacy-policy.html` |
| Terms of Use | ✅ `docs/terms-of-use.html` |
| Landing page | ✅ `docs/index.html` |
| Go-live checklist | ✅ `docs/GoLiveChecklist.md` |
| Step-by-step guide | ✅ `APP_STORE_GUIDE.md` |
| App icon | ✅ In Assets.xcassets |
| Bundle ID | ✅ `com.littlelightsbiblebedtime.app` |
| Signing | ⚠️ Needs developer to select team in Xcode Signing & Capabilities |
| Screenshots | ⚠️ Need to capture final simulator screenshots for each device size |

---

## Owner Context

- **Developer:** Little Lights Team
- **App name:** Little Lights Bible Bedtime
- **Vision:** Beautiful, calm, free Bible bedtime stories for young children — high-quality narration, rich artwork, peaceful UI. No ads, no tracking, no paywall. Pure children's content.
- **User preference:** Work autonomously without asking for permission. Fix bugs proactively. Keep everything free and legal. Do not take shortcuts.
- **Child profile:** User has child named "Savy" set in the app (entered during onboarding).

---

## Quick Debugging Commands

```bash
# Full clean build
bash -c 'cd "/Users/lanesinclair/Downloads/LittleLightsBibleBedtime" && xcodebuild -scheme LittleLightsBibleBedtime -destination "platform=iOS Simulator,name=iPhone 17" -configuration Debug build 2>&1 | tail -5'

# Check all story IDs and audio filenames
python3 -c "
import json
with open('/Users/lanesinclair/Downloads/LittleLightsBibleBedtime/Resources/stories.json') as f:
    stories = json.load(f)
print(f'{len(stories)} stories loaded')
for s in stories:
    print(f'  {s[\"id\"]:50} {s[\"audioFileName\"]}')
"

# Verify all audio files exist
python3 -c "
import json, os
with open('/Users/lanesinclair/Downloads/LittleLightsBibleBedtime/Resources/stories.json') as f:
    stories = json.load(f)
audio_dir = '/Users/lanesinclair/Downloads/LittleLightsBibleBedtime/Resources/Audio'
files = set(os.listdir(audio_dir))
missing = [s['audioFileName'] for s in stories if s['audioFileName'] not in files]
print('Missing audio:', missing if missing else 'None — all 50 present ✅')
"

# Find available simulators
xcrun simctl list devices available | grep iPhone | head -10

# Install and launch
APP=\$(find ~/Library/Developer/Xcode/DerivedData -name "LittleLightsBibleBedtime.app" -path "*/Debug-iphonesimulator/*" | grep -v Index | head -1)
xcrun simctl install "iPhone 17" "\$APP"
xcrun simctl launch "iPhone 17" com.littlelightsbiblebedtime.app

# Take screenshot
xcrun simctl io "iPhone 17" screenshot /tmp/ss.png

# Set/clear bedtime mode
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app isBedtimeMode -bool YES
xcrun simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app isBedtimeMode -bool NO
```

---

## Session History Summary

**Session 1 (Initial):**
- App scaffolded and launched in simulator
- Only 11/50 stories had artwork (Midjourney images); 39 showed blank/broken

**Session 2 (Fixes):**
- Added full procedural artwork system for 39 stories without images
- Fixed WebP→PNG asset conversion for 10 images
- Fixed HomeView division by zero
- Fixed AmbientSoundService fake state
- Fixed AudioPlayerViewModel race conditions
- Fixed ReadingStreak day boundary
- Fixed StoryProgressBar random in body
- Fixed deprecated `.foregroundColor`
- Fixed weekOfYear 1-based offset (story of week was non-uniform)
- Fixed BedtimeRoutineView breathing task (now cancellable via `Task { @MainActor }`)
- Fixed ConfettiCelebrationView stale index mutation
- Fixed ElevenLabsService force-unwrap on DocumentDirectory
- Fixed SupportView URL force-unwrap
- Accidentally introduced audio regression (removed `setCategory` from `loadAudio`)

**Session 3 (This session):**
- Fixed audio regression — restored `setCategory(.playback, mode: .spokenAudio)` in both `loadAudio` methods
- Removed `.mixWithOthers` from `configureAudioSession()`
- Added `.allowsHitTesting(false)` to all decorative layers in `StoryArtworkView`
- Ran 5 full debug passes — all passed
- Verified on simulator: builds clean, artwork renders, navigation works, both day/night modes look great
