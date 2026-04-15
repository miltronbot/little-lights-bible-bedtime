# Remaining Tasks to Ship Little Lights Bible Bedtime

## Status: Ready for App Store Submission
The app is feature-complete. All code, audio, and content are production-ready. The following tasks are administrative/manual steps that require human action in Xcode and App Store Connect.

---

## Pre-Submission (Do These First)

### 1. Enroll in Apple Developer Program
- Go to https://developer.apple.com/programs/enroll/
- Cost: $99/year
- Timeline: 24-48 hours for approval
- Required before you can submit anything

### 2. Host Legal Documents
Your privacy policy and terms of use need to be publicly accessible URLs.
- **Easiest option:** Create a GitHub repo, push the `docs/` folder, enable GitHub Pages
- Files ready to host: `docs/privacy-policy.html`, `docs/terms-of-use.html`, `docs/index.html`
- You'll need the live URLs when filling out App Store Connect

### 3. Set Up Xcode Signing
- Open `LittleLightsBibleBedtime.xcodeproj` in Xcode
- Go to project settings → Signing & Capabilities
- Select your Apple Developer team
- Xcode will automatically create provisioning profiles

### 4. Test on Physical Device
- Connect an iPhone running iOS 17+
- Build and run the app
- Walk through: Onboarding → Home → Library → Play a story → Favorites → Bedtime Routine → Settings
- Test sleep timer, ambient sounds, bedtime mode toggle
- Test IAP flow using StoreKit sandbox (Products.storekit)

---

## App Store Connect Setup

### 5. Create App in App Store Connect
- Go to https://appstoreconnect.apple.com
- Click "+" → New App
- **Platform:** iOS
- **Name:** Little Lights Bible Bedtime
- **Primary Language:** English (U.S.)
- **Bundle ID:** com.littlelightsbiblebedtime.app
- **SKU:** littlelightsbiblebedtime

### 6. Fill in App Information
- All copy is in `docs/AppStoreListing.md`
- **Subtitle:** Bible Stories for Peaceful Sleep
- **Category:** Books (Primary), Education (Secondary)
- **Age Rating:** 4+ (no objectionable content)
- **Content:** All 50 stories are free (no in-app purchases required)
- **Privacy Policy URL:** [your hosted URL from step 2]

### 7. Capture Screenshots
Need screenshots for these device sizes:
- iPhone 6.7" (iPhone 15 Pro Max) — 1290 x 2796
- iPhone 6.5" (iPhone 11 Pro Max) — 1242 x 2688
- iPhone 5.5" (iPhone 8 Plus) — 1242 x 2208

Recommended 6 screenshots showing:
1. Home screen with "Tonight's Story"
2. Story library grid
3. Story detail with audio player
4. Bedtime routine flow
5. Sleep features (timer, ambient sounds)
6. Rewards/streaks screen

Use Xcode Simulator → File → Screenshot (Cmd+S)

---

## Build & Submit

### 8. Archive and Upload
- In Xcode: Product → Archive
- In the Organizer window: Distribute App → App Store Connect → Upload
- Wait for processing (5-15 minutes)

### 9. Submit for Review
- Back in App Store Connect, select the uploaded build
- Ensure all metadata, screenshots, and IAP are filled in
- Click "Submit for Review"
- Timeline: Typically 24-48 hours
- Common rejection reasons to watch for:
  - Missing screenshots for required device sizes
  - Privacy policy URL not accessible
  - IAP not properly configured in App Store Connect

---

## Post-Launch (Optional Enhancements)
- [ ] Add unit tests for ViewModels and Services
- [ ] Add push notification reminders for bedtime
- [ ] Add iCloud sync for favorites and streaks
- [ ] Add iPad-optimized layouts
- [ ] Add Home Screen widgets
- [ ] Consider professional voiceover (current TTS is good quality)
- [ ] Add more stories beyond 50
