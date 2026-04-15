
# Thorough Implementation Plan

## Scope
Build and validate an iPhone-first SwiftUI bedtime story app for kids with:
- 21 Bible bedtime stories
- 5 free stories
- premium unlock flow
- favorites
- bedtime mode
- local audio playback
- privacy / terms / support screens
- Bible-themed placeholder artwork

## Current package contents
This package includes:
- a real Xcode project file
- source files for the MVP
- all 21 story records in JSON
- 5 generated MP3 narration files for the free stories
- markdown privacy and terms documents

## Build phases

### Phase 1 — Open and run in Xcode
- Open `LittleLightsBibleBedtime.xcodeproj`
- Verify target opens successfully
- Confirm resources and source files are included in the target
- Run on simulator, then on a real iPhone

### Phase 2 — Functional verification
- Check Home, Library, Favorites, Settings
- Confirm premium stories route to the paywall
- Confirm free stories open and render correctly
- Confirm search and category filters work
- Confirm favorites persist across relaunch
- Confirm bedtime mode persists across relaunch
- Confirm MP3 playback works for the 5 free stories

### Phase 3 — Content and UX polish
- Replace any remaining rough copy
- Review typography sizing in bedtime mode
- Refine placeholder artwork or replace with custom illustration assets
- Tighten support copy and legal text
- Add a real app icon and launch screenshots

### Phase 4 — Monetization
- Replace the local purchase stub with StoreKit 2
- Create a non-consumable full-library unlock in App Store Connect
- Test local StoreKit configuration
- Test sandbox / TestFlight purchase and restore flows

### Phase 5 — Submission
- Final bug pass on real devices
- Final content review
- App Store metadata
- Submit app + first in-app purchase

## Definition of done before StoreKit
- App builds and launches cleanly
- All tabs and navigation are stable
- Library shows all 21 stories
- Premium gating works with the stub
- Favorites persist
- Bedtime mode persists
- The 5 free narration files play correctly
- Privacy / terms / support screens are complete

## Risk notes
- The included MP3s are development-grade synthetic narration, not studio voiceover
- The included Xcode project is generated for convenience and may still need minor Xcode-side adjustments depending on your local version
- StoreKit is not connected yet
