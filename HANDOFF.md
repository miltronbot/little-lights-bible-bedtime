# Firefly Bible Bedtime — Session Handoff
**Last updated:** June 12, 2026 (end of the v2 sprint)
**Status:** v2.0 feature-complete on `main` · zero build warnings · v1.0 sitting in App Store review
**Read `CLAUDE.md` first** for the quick-reference facts; this file is the deep handoff.

---

## 1. Where things stand RIGHT NOW

- **v1.0 is in Apple's review queue**, submitted by the owner. ⚠️ **OPEN QUESTION:** it may still be named "Little Lights Bible Bedtime" in App Store Connect. The app was renamed to **Firefly Bible Bedtime** (PR #20) *after* submission because "Little Lights: Bible Puzzles" already exists on the store. The owner needs to either edit the ASC name field (App Information → Name) if editable, developer-reject + rename + resubmit, or let v1.0 launch under the old name and rename via update. **Ask the owner about this first in a new session.**
- **v2.0 is done on `main`** (MARKETING_VERSION = 2.0, build 1) and is a massive upgrade over the submitted v1.0 — 40 PRs total, ~#20–#40 being the rebrand + v2 work.
- The repo: `https://github.com/miltronbot/little-lights-bible-bedtime` (public). Flow used throughout: branch → PR → merge to main, every change builds clean before merging.
- **Bundle ID never changes:** `com.littlelightsbiblebedtime.app` (permanent for the ASC record; invisible to users).
- Signing: team `ANY3QHU2YX`, automatic, Apple Distribution cert in keychain. The owner's Apple ID is signed into Xcode. No physical device has ever been registered (cable was charge-only).

## 2. What the app is now (v2.0)

A free, fully offline, COPPA-clean SwiftUI bedtime app: 50 narrated Bible stories (bundled MP3s), single Midjourney illustration per story, starry "Wise Men" teal-night theme app-wide, Lumi the firefly as the living mascot/brand.

**Navigation:** 5 tabs (Home / Library / **Games** / Rewards / Settings — Favorites moved to the side menu when Games took its slot; iOS hides a 6th tab behind "More") + two left drawers — Home's hamburger menu (`SideMenuView`: themes, My Favorites, 7-Day Journeys, Bedtime Routine, Lumi's Night Sky, Parent Dashboard — the designated home for new features via `SideMenuDestination`) and Library's filter drawer (`LibraryFilterMenu`, same file: collapsible Ages/Themes drop-down sections, live "Show N stories" button, dismissible filter pills on the page).

**Audio:** lock-screen Now Playing + remote commands + interruption auto-resume (`AudioPlayerViewModel`), Sleepy Speed 0.85x, Tonight's Queue (chain 3 stories), sleep timer, 6 ambient sounds, Lights Out mode (`LightsOutView` — near-black screen, audio continues; Kid Lock setting = 3s-hold to wake instead of double-tap).

**Kids UX:** read-along transcript highlighting — the paragraph being narrated gets an accent background + leading bar, estimated from playback progress via `ReadAlongTextView.paragraphIndex` (no word timings exist for the MP3s); on the story detail screen (highlight only) and the Bedtime Routine story step (full transcript + gentle auto-scroll that backs off for 4s whenever the reader scrolls by hand). Also: instant ▶ play buttons on story cards, autoplay-on-open (default ON, toggle in Settings), completion stars on cards, pulsing Read to Me, wandering tappable Lumi on story screens (glides to center before speaking — bubble max 210pt), MagicTouchLayer sparkle taps on hero art, Breathe-with-Lumi breathing exercise.

**Gamification (the engagement architecture):**
- Per story: Sleep Star + collectible (50, one per story — Noah = Dove, never a rainbow) + ~1-in-7 shooting-star bonus star
- Nightly: Tonight's Goals on Home (listen / practice a verse / breathe → Golden Night bonus star) — `GoalsTracker`
- Weekly: Weekly Challenge on Rewards (theme rotates by ISO week, progress computed from `storiesReadDates`, deep-links to themed Library, bonus star once per week)
- Levels: `FireflyLevel` — 10 named ranks from Sleep Stars (Tiny Spark → Light of the World), progress ring on Rewards, `LevelUpCelebrationView` confetti fires via `readingStreak.leveledUpTo`
- Weekly+: **7-Day Journeys** (`JourneysView`/`JourneyDetailView` via the side menu — 4 themed week plans in `Journey.all` sequencing existing stories; per-child completed-day sets in `JourneyProgressManager` under `journeyProgress` keys, union-merged by iCloud)
- Long-term: 27 badges (emoji cards, tap for progress via `BadgeDetailSheet`), Treasure Sets (7 theme sets in `CollectionAlbumView`), **Lumi's Night Sky** (`NightSkyView` — per-child decoratable scene: an always-available sticker palette (fun from day one) PLUS earned collectible treasures; tap to place, drag, double-tap OR hold to put back; **7 selectable backdrops** (`NightSkyScene`: Starry/Sunset/Ocean/Meadow/Candy/Rainbow/Snowy — rich procedural compositions, one seeded Canvas each: sun-into-sea with shimmer path + birds, fish/waves/seaweed, hills/grass/flowers/fireflies, candy clouds, rainbow arcs, snowman + frosted pines + drifts; picker swatches in the drawer, choice per child in `nightSky.scene`, the nav title follows the scene via `NightSkyScene.title`); the drawer TUCKS AWAY (chevron ↔ floating grid button) so the whole scene is usable; collectibles keep the original `nightSky.positions` store, palette stickers live in a parallel `nightSky.stickers` store so old layouts load untouched; per profile, mirrored to iCloud)

**Games tab** (`GamesView` — all offline/procedural, every ending encouraging): Treasure Match (flip-card pairs from 6 random collectibles, best-flips in `game.memoryMatch.bestMoves`), Story Quiz (6 random questions per round from the 24-question hand-written `QuizQuestion.bank` — keep new questions unambiguous and gentle), and a Verse Practice door into the existing `MemoryVerseGameView` on a random verse-bearing story.

**Wind-Down auto mode** (Settings toggle, default OFF): opening the app at/after the family's bedtime (shared `bedtimeHour`/`bedtimeMinute` keys with NotificationService) flips bedtime mode and stages Tonight's Story — `WindDownService.shouldTrigger` is pure/testable, fires once per night via a `windDownLastFired` day-stamp, checked from BOTH `onAppear` (cold launch) and `scenePhase` onChange (re-foreground); staged story is cleared on the first pre-bedtime open of a new day. Never auto-plays. `StoryLibraryViewModel.pendingTonightsStory` drives the Home banner + card highlight.

**Parent Voice** (StoryDetailView row → `.sheet`, `ParentVoiceSheet`): a grown-up records narration per story + per child to `Documents/ParentVoice/<profile>/<storyID>.m4a` (`VoiceRecordingService`; mic permission via iOS 17 `AVAudioApplication`; `NSMicrophoneUsageDescription` in Info.plist). Playback hooks in at the single chokepoint at the top of `AudioPlayerViewModel.loadStory` — recording exists → it plays instead of the bundled MP3, so lock screen/queue/sleep timer all work unchanged. Recording flips the session to `.playAndRecord` ONLY inside `startRecording`; the playback paths restore `.playback`. Failed/unsuccessful recordings are deleted immediately so a stub file can never shadow real narration. With 2+ profiles, "Also save it for…" chips copy the take into siblings' folders (each child keeps an independent copy). On-device only, never uploaded.

**Family:** up to 4 child profiles (per-child streaks/favorites/collectibles via `ProfileScope` keys, Home-greeting switcher menu), iCloud KVS sync (`CloudSyncService` — union merges for sets, most-progress-wins for streaks; `Firefly.entitlements`), Verse of the Day card on Home, shareable story postcards (`PostcardRenderer`), story-specific Talk About It questions (all 50 in stories.json), memory-verse game (marks the nightly goal on finish), Siri "Play tonight's story" (`FireflyAppIntents` → `.playTonightsStory` notification handled at app root).

## 3. Architecture gotchas — DO NOT RELEARN THESE THE HARD WAY

1. **Full-screen covers fire `onDisappear`** on StoryDetailView. The stop-narration-on-leave call is guarded by `!showLightsOut && !showAffirmations`. Any NEW `.fullScreenCover` from the detail view must join that guard or it will kill audio.
2. **Never nest a Button inside a NavigationLink's label** — both gestures deadlock silently. `StoryCardView` is the pattern: NavigationLink wraps the content; the play Button is a *sibling* in the HStack.
3. **Drawer/overlay panels**: render `if isOpen` with `.transition(.move(edge: .leading))` inside a `.frame(maxWidth:.infinity, maxHeight:.infinity, alignment:.leading)` ZStack. Offset-hiding leaves a visible left-edge shading sliver (owner caught this).
4. **`BadgeDetailSheet.targets` must mirror `ReadingStreak.checkBadges()` thresholds** — maintained in two places.
5. **pbxproj is objectVersion 56** (explicit file refs). Every new .swift file needs 4 insertions: PBXBuildFile, PBXFileReference, group children, Sources phase. Established ID pattern `E0ABCDEF1234567890ABCC#` / `E01234567890ABCDEF1234C#` — last used **CB** (GamesView; C7–CA are the four Journey files). Next: CC. (The Wind-Down/Parent-Voice files used one-off `…D11`/`F2…` IDs — harmless, but stick to the C-series.) (Appending a struct to an existing registered file avoids this entirely.)
6. **Audio session mode is `.default`** (NOT `.spokenAudio` — old docs lied). setCategory in both loadAudio methods + startup; never `.mixWithOthers`.
7. **ImageRenderer postcards: render once** into `@State` in `.task` — the detail view redraws 4×/sec during playback; a render-per-redraw is a real perf bug (was caught and fixed).
8. StoryArtworkView decorative layers stay `.allowsHitTesting(false)`; MagicTouchLayer lives ONLY on the detail hero, never on cards.

## 4. Owner preferences (PERMANENT — also in memory files)

- **Never** "hiding/hid God's Word in your heart" → say "missing word" / "learning by heart"
- **Never** the word "Affirmations" → say **"Blessings"** ("Goodnight Blessings")
- Free forever, no ads, no analytics, COPPA-clean (no accounts/servers — iCloud KVS only)
- Work autonomously; branch→PR→merge each change; additive changes only — never lose existing work
- Under-icon display name is **"Firefly"** (iOS strips spaces from long names); full name lives in ASC
- Home header reads "Bible Bedtime **Stories**" (NOT the app name — owner request, PR #22)

## 5. Deferred backlog (rough priority)

1. **Update `docs/AppStoreListing.md` for 2.0** — description/What's New do NOT yet mention the v2 features (lock screen, Lights Out, iCloud, Siri, gamification, Night Sky). Then regenerate `~/Desktop/AppStoreCopy/` text files.
2. **App Store screenshot refresh** — `~/Desktop/AppStoreScreenshots/` (iPhone-6.9 ×6 at 1320×2868, iPad-13 ×5 at 2064×2752) predates the sky/drawers/Lumi/gamification. Full recapture before the 2.0 submission.
3. **WidgetKit extension** (streak + verse-of-day widgets) — needs a new Xcode target; create IN XCODE, not by pbxproj scripting.
4. **v2.5 headliners:** verse songs, Spanish edition (TTS pipeline exists in `scripts/`), coloring-page PDFs, CarPlay. (Parent Voice recording shipped; a teleprompter/read-along view while recording would be a nice follow-up.)

## 6. Device/TestFlight verification checklist (simulator cannot test these)

- Lock-screen Now Playing card + AirPods controls (registration PROVEN via `mediaremoted` logs; the visual card doesn't render in simulator)
- Parent Voice mic capture (`AVAudioRecorder.record()` returns false in the simulator — host/Bluetooth input limitation; everything around it is sim-proven: file layout, failed-start cleanup, saved-state UI, and the playback chokepoint that swaps a recording in for the bundled MP3)
- Siri phrases ("Hey Siri, play tonight's story in Firefly")
- iCloud sync across two devices (KVS silently no-ops without an iCloud account in sim)
- Lights Out gestures incl. Kid Lock 3s-hold; interruption auto-resume during a real phone call
- The first device archive will register the iCloud KVS capability via automatic signing (`-allowProvisioningUpdates`)

## 7. Working in this environment

- **Build:** `xcodebuild -scheme LittleLightsBibleBedtime -destination "platform=iOS Simulator,name=iPhone 17" -configuration Debug build` — keep ZERO warnings.
- **Run:** install to the "iPhone 17" sim, `simctl launch com.littlelightsbiblebedtime.app`, screenshot via `simctl io`. Skip onboarding: `simctl spawn "iPhone 17" defaults write com.littlelightsbiblebedtime.app hasCompletedOnboarding -bool YES`.
- **UI automation quirks (hard-won):** `cliclick` into the Simulator frequently loses the FIRST click of each invocation (focus-eat) — use `c:X,Y w:400 c:X,Y` for buttons, but NEVER on toggles (double-fires) and NEVER on screens where the second tap could double-tap-dismiss. Re-fetch window geometry each session (`osascript … get {position, size} of window 1` — enumerate windows by name; "window 1" can be stale when multiple sims opened). The window has a ~50px title strip + bezel before content — calibrate from `screencapture -x -R<window rect>`. Sim clock drifts in long sessions.
- **The owner sometimes uses this Mac concurrently** — if a browser/dev-portal window appears in a desktop capture, STOP mouse automation immediately and verify via builds/logs instead.
- **ASC upload without a device (proven, used for v1.0):** archive with `CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO`, then `xcodebuild -exportArchive` with plist `{method: app-store-connect, teamID: ANY3QHU2YX, signingStyle: automatic, destination: upload}` + `-allowProvisioningUpdates`. (First-ever upload failed on missing iPad landscape orientations — fixed in PR #19, all four declared.)
- **Hosted pages** (registered in ASC): `https://miltronbot.github.io/little-lights-bible-bedtime/privacy-policy.html` + `terms-of-use.html` + landing — served from `docs/` via GitHub Pages.
- Desktop artifacts: `~/Desktop/AppStoreScreenshots/` (ASC-sized sets) and `~/Desktop/AppStoreCopy/` (numbered paste-ready listing text).

## 8. PR ledger (the whole saga)

- **#1–#19** — v1: bug fixes, name removal, single-photo artwork, v1.1 features (profiles, queue, Talk About It, verse game, sparkles), rewards expansion (50 collectibles/27 badges), reward detail sheets + Collection Book, launch prep (privacy manifest, signing, screenshots, listing), upload fixes (#19 iPad orientations → upload succeeded).
- **#20–#25** — Rebrand: Firefly name + icon (#20–21), "Bible Bedtime Stories" header (#22), side menu (#23), wandering Lumi + drawer shading fix (#24), Wise Men sky app-wide (#25).
- **#26–#36** — v2 sprint: lock-screen player (#26), Lights Out (#27), Blessings rename (#28), kid-friendly pass (#29), iCloud sync (#30), Breathe with Lumi + Sleepy Speed (#31), Verse of the Day + postcards (#32), Siri (#33), Kid Lock (#34), v2.0 docs (#35), Lumi bubble fix (#36).
- **#37–#40** — Gamification: levels/goals/sets (#37), level-ups/weekly challenge/shooting stars/Night Sky (#38), Library filter drawer (#39), drop-down sections (#40).
