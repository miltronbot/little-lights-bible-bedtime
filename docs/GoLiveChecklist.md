# Firefly Bible Bedtime — Go Live Checklist

## Phase 1: Apple Developer Account (Do This First)
- [ ] Go to https://developer.apple.com/programs/enroll/
- [ ] Sign in with your Apple ID (or create one)
- [ ] Enroll as an **Individual** ($99/year)
- [ ] Wait for approval (usually instant, can take up to 48 hours)

## Phase 2: Test in Simulator
- [ ] Reset onboarding: In simulator, go to Settings app → scroll to Firefly → delete app data, OR delete the app and reinstall
- [ ] Walk through onboarding (enter child name, pick age, set bedtime reminder)
- [ ] Test home screen (check Recently Read, Favorites, Tonight's Story, Story of the Week, Seasonal Pick all display)
- [ ] Play a story end-to-end (tap play, verify narration audio works)
- [ ] Test ambient sounds (select rain, ocean, etc. during story playback)
- [ ] Test Bedtime Routine flow (Breathing → Story → Prayer → Goodnight)
- [ ] Add a story to favorites, verify it appears on home screen
- [ ] Check Settings → Bedtime Reminder toggle and time picker
- [ ] Check Parent Dashboard
- [ ] Test Bedtime Mode toggle (dark theme)
- [ ] Verify sleep timer works

## Phase 3: Capture Screenshots
Apple requires screenshots for these device sizes. Run the simulator at each size and capture:

### Required Sizes (current ASC requirements — DONE, see Status below):
1. **6.9" iPhone** (iPhone 17 Pro Max): 1320 x 2868 px — smaller iPhone sizes scale down automatically
2. **13" iPad** (iPad Pro 13-inch): 2064 x 2752 px

Captured sets live in `~/Desktop/AppStoreScreenshots/`.

### Screens to Capture (6 screenshots per device):
1. **Home screen** — showing greeting, Tonight's Story, streak banner
2. **Story Library** — showing all categories and story cards
3. **Story Detail** — with audio player visible, bedtime mode ON
4. **Bedtime Routine** — the guided breathing step or story step
5. **Bedtime Mode** — starry night background, ambient sounds
6. **Rewards** — showing badges and Sleep Stars

### How to Take Simulator Screenshots:
- Cmd+S in the simulator captures a screenshot to your Desktop
- Or: File → Save Screen (in Simulator menu)

## Phase 4: App Store Connect Setup
Once your developer account is approved:

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform:** iOS
   - **Name:** Firefly Bible Bedtime
   - **Primary Language:** English (U.S.)
   - **Bundle ID:** com.littlelightsbiblebedtime.app
   - **SKU:** LittleLightsBibleBedtime
4. Under **App Information:**
   - **Subtitle:** Bible Stories for Sleepy Time
   - **Category:** Education (Primary), Books (Secondary)
   - **Content Rights:** Does not contain third-party content
   - **Age Rating:** 4+ (answer all questions — no violence, no mature content)
5. Under **Pricing and Availability:**
   - **Price:** Free
   - **Availability:** All territories
6. Under **App Privacy:**
   - Select **Data Not Collected** (the app collects zero user data)
   - This is critical for COPPA compliance

## Phase 5: Prepare the Submission

### Version Information:
- Copy the **full description** from docs/AppStoreListing.md
- Copy the **keywords** (optimized 98-char version): `bible stories kids, bedtime stories, sleep stories, children audio, faith kids, prayer app`
- Copy the **What's New** text from docs/AppStoreListing.md
- Upload your 6 screenshots for each device size

### App Review Information:
- **Contact:** Your name, email, phone
- **Notes for Review:** "This is a children's Bible bedtime story app. It is 100% free with no ads or in-app purchases. It is COPPA-compliant and collects zero user data. The app includes 50 narrated Bible stories, guided bedtime routines, and ambient sleep sounds."

## Phase 6: Build and Upload

### In Xcode:
1. Select your **Team** (your developer account) in:
   - Project → Signing & Capabilities → Team
   - Make sure "Automatically manage signing" is checked
2. Set the device to **Any iOS Device (arm64)** (not a simulator)
3. **Product → Archive**
4. When archive completes, the Organizer window opens
5. Click **Distribute App** → **App Store Connect** → **Upload**
6. Wait for processing (5-30 minutes)

### Back in App Store Connect:
- Your build will appear under **TestFlight** and **App Store** tabs
- Select the build for your App Store submission
- Click **Submit for Review**

## Phase 7: App Review
- Apple reviews typically take 24-48 hours
- They may ask questions — respond promptly
- Common children's app review flags:
  - COPPA compliance (you're covered — zero data collection)
  - Age rating accuracy (4+ is correct)
  - Content appropriateness (Bible stories are fine)

## Quick Reference: Files Ready for You

| What | Where |
|------|-------|
| App Store description + keywords | docs/AppStoreListing.md |
| Privacy Policy (web) | docs/privacy-policy.html |
| Terms of Use (web) | docs/terms-of-use.html |
| **Privacy Policy URL (live, for ASC)** | https://miltronbot.github.io/little-lights-bible-bedtime/privacy-policy.html |
| **Terms of Use URL (live)** | https://miltronbot.github.io/little-lights-bible-bedtime/terms-of-use.html |
| **Screenshots (ASC-ready)** | ~/Desktop/AppStoreScreenshots/ (iPhone-6.9: 1320×2868 ×6, iPad-13: 2064×2752 ×5) |

## Status (updated June 10, 2026)

Already done — no action needed:
- [x] Apple Developer enrollment (approved)
- [x] Signing team set in project (ANY3QHU2YX, automatic signing)
- [x] Privacy manifest (PrivacyInfo.xcprivacy) — required since 2024, verified in bundle
- [x] iPhone + iPad device support unified
- [x] Privacy policy & terms hosted on GitHub Pages (URLs above)
- [x] Screenshots captured at required sizes (dark mode, current UI)
- [x] Release configuration builds clean
- [x] Export compliance preset (ITSAppUsesNonExemptEncryption = NO)

Remaining — requires the owner's Apple ID:
- [ ] Xcode → Settings → Accounts → sign in (archive fails with "No Accounts" until then)
- [ ] Create the app record in App Store Connect (Phase 4)
- [ ] Paste listing, upload screenshots, set privacy URL, complete App Privacy → Data Not Collected (Phase 5)
- [ ] Archive & upload (Phase 6)
- [ ] Submit for review (Phase 7)
| Launch guide (detailed) | docs/LaunchGuide.md |
| This checklist | docs/GoLiveChecklist.md |

## Privacy Policy & Terms Hosting
Before submitting, you need to host the privacy policy and terms online. Options:
1. **GitHub Pages** (free): Push docs/ folder to a GitHub repo, enable Pages
2. **Any web hosting**: Upload privacy-policy.html and terms-of-use.html
3. Enter the URLs in App Store Connect under App Information

## Bundle ID Note
Your bundle ID is `com.littlelightsbiblebedtime.app`. When you set up the App ID in your developer account, use this exact identifier.
