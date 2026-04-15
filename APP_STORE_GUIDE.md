# Little Lights Bible Bedtime — App Store Submission Guide

## Step 1: Apple Developer Program Enrollment

1. Go to https://developer.apple.com/programs/enroll/
2. Sign in with your Apple ID (or create one)
3. Enroll as an **Individual** ($99/year)
4. Complete identity verification (may take 24–48 hours)
5. Once approved, you'll have access to **App Store Connect** and can set your Team ID

---

## Step 2: Xcode Project Configuration

Open `LittleLightsBibleBedtime.xcodeproj` in Xcode, then:

### Set Your Team
1. Select the project in the navigator → select the **LittleLightsBibleBedtime** target
2. Go to **Signing & Capabilities**
3. Check **Automatically manage signing**
4. Select your **Team** from the dropdown (your new Apple Developer account)
5. Verify the **Bundle Identifier** is: `com.littlelightsbiblebedtime.app`

### Add In-App Purchase Capability
1. Still in **Signing & Capabilities**
2. Click **+ Capability**
3. Search for and add **In-App Purchase**
4. Also verify **Background Modes** is present with **Audio** checked

### Configure StoreKit Testing (Local)
1. Go to **Product → Scheme → Edit Scheme**
2. Select **Run** → **Options**
3. Under **StoreKit Configuration**, select `Products.storekit`
4. This lets you test purchases in the simulator without a real App Store product

### Build & Test
1. Select an iPhone simulator (iPhone 15 or newer recommended)
2. Build and run (Cmd+R)
3. Verify all 50 stories load, audio plays, and the purchase flow works
4. Test on a **real device** before submitting

---

## Step 3: App Store Connect Setup

### Create the App
1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Little Lights Bible Bedtime
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: com.littlelightsbiblebedtime.app
   - **SKU**: LittleLightsBibleBedtime1

### In-App Purchases
No in-app purchases needed — the app is completely free. Skip this step.

---

## Step 4: App Store Metadata

### App Name
**Little Lights Bible Bedtime**

### Subtitle (30 chars max)
**Bible Bedtime Stories & Sleep**

### Description
```
The most complete Bible bedtime experience for kids — completely free. 50 stories, sleep timer, ambient sounds, and a guided bedtime routine to help your child drift off with faith, peace, and comfort.

FEATURES:
• 50 Bible bedtime stories with audio narration — ALL FREE
• Sleep Timer with gentle fade-out (15, 30, 45, or 60 minutes)
• Ambient sounds: gentle rain, ocean waves, crickets, fireplace, and more
• Guided Bedtime Routine: story + prayer + soothing sounds in one flow
• Reading Streaks and Sleep Stars rewards to build consistent bedtime habits
• Bedtime Mode dims the screen for comfortable nighttime reading
• Memory Verse with every story to help kids learn scripture
• Age-appropriate grouping: Ages 3-5, 6-8, and 9-12
• "Tonight's Story" — a fresh story suggestion every night
• Save favorites for quick bedtime access
• Search and filter by theme: Trust, Courage, Peace, Love, Hope, Prayer, Kindness
• Adjustable font size and reading preferences
• No ads, no subscriptions, no in-app purchases, no data collection — ever

50 BIBLE STORIES INCLUDING:
Noah and the Big Boat, Daniel and the Lions, Jesus Calms the Storm, The Lost Sheep, David and Goliath, Jonah and the Big Fish, Baby Moses, The Good Samaritan, Creation Story, Abraham and the Stars, Ruth and Naomi, Jesus Walks on Water, The Empty Tomb, and many more!

Designed with love for families. Safe, simple, and screen-time you can feel good about.
```

### Keywords (100 chars max)
```
bible,bedtime,stories,kids,children,prayer,christian,faith,sleep,narration,jesus,family
```

### Category
- **Primary**: Education
- **Secondary**: Books

### Content Rating
- **Age Rating**: 4+ (no objectionable content)

### Privacy Policy URL
You'll need to host your privacy policy online. Options:
- GitHub Pages (free)
- Your own website
- A service like Termly or iubenda

The privacy policy text is already in `Support/PrivacyPolicy.md`.

### Support URL
Use a simple page or `mailto:support@littlelightsbiblebedtime.com`

---

## Step 5: Screenshots

You need screenshots for these sizes:

| Device | Size (pixels) |
|--------|--------------|
| iPhone 6.7" (15 Pro Max) | 1290 x 2796 |
| iPhone 6.5" (11 Pro Max) | 1242 x 2688 |
| iPhone 5.5" (8 Plus) | 1242 x 2208 |

### Recommended Screenshots (5–8 screens):
1. **Home screen** — Tonight's Story, streak banner, bedtime routine card
2. **Library** — browse all 50 stories with age and category filters
3. **Story detail** — reading a story with bedtime mode ON
4. **Bedtime Routine** — sleep timer, ambient sounds, guided flow
5. **Rewards** — Sleep Stars, badges, and reading streaks
6. **Audio player** — "Read to Me" with sleep timer active
7. **Memory Verse** — scripture verse display in story view

### How to Capture
1. Run the app on simulator at each required device size
2. Use **Cmd+S** in Simulator to save screenshots
3. Consider using a screenshot framing tool like **Screenshots Pro** or **Previewed** to add device frames and marketing text

---

## Step 6: App Icon

The app currently uses a placeholder icon. You'll need a **1024x1024** PNG (no transparency, no rounded corners — Apple applies the mask).

**Design suggestions** for your brand:
- A soft, glowing crescent moon with small stars
- Warm indigo/navy background (matching the app's bedtime mode palette)
- A gentle warm glow or small book icon
- Keep it simple and readable at small sizes

You can create one with Canva, Figma, or hire a designer on Fiverr.

Place the final icon in `LittleLightsBibleBedtime/Assets.xcassets/AppIcon.appiconset/`

---

## Step 7: Pre-Submission Checklist

- [ ] App builds and runs on a real iPhone with no crashes
- [ ] All 50 stories display correctly with text, takeaway, and prayer
- [ ] Audio narration plays for all 50 stories
- [ ] Favorites save and persist after app restart
- [ ] Bedtime mode toggles correctly and persists
- [ ] Sleep timer works and audio fades out correctly
- [ ] Ambient sounds play and volume controls work
- [ ] Reading streaks and Sleep Stars track correctly
- [ ] Privacy Policy and Terms of Use display properly
- [ ] Support email link works
- [ ] App icon is set (1024x1024)
- [ ] `ITSAppUsesNonExemptEncryption` is set to NO in Info.plist (already done)
- [ ] Bundle identifier matches App Store Connect

---

## Step 8: Submit for Review

### Upload the Build
1. In Xcode: **Product → Archive**
2. In the Organizer window, click **Distribute App**
3. Choose **App Store Connect** → **Upload**
4. Follow the prompts to upload

### Submit in App Store Connect
1. Go to your app in App Store Connect
2. Select the uploaded build
3. Fill in all metadata (description, screenshots, etc.)
4. Set the In-App Purchase to **Submit with This Version**
5. Answer the App Review questions:
   - **Export compliance**: Select "No" (encryption flag is already set)
   - **Content rights**: Confirm you have rights to all content
   - **Advertising ID**: Select "No" (the app has no ads)
6. Click **Submit for Review**

### Review Timeline
- First submissions typically take 24–48 hours
- If rejected, Apple provides specific feedback — fix and resubmit
- Common first-time rejection reasons:
  - Missing privacy policy URL
  - App icon issues
  - IAP metadata incomplete
  - Crashes during review

---

## Post-Launch

- **Monitor reviews** in App Store Connect
- **Respond to support emails** promptly
- **Plan updates**: more stories, improved narration (professional voiceover), seasonal content
- **Consider** adding widgets, Apple Watch companion, or iCloud sync in future versions

---

## Quick Reference: Key Identifiers

| Item | Value |
|------|-------|
| Bundle ID | `com.littlelightsbiblebedtime.app` |
| IAP | None — completely free |
| Price | Free |
| Min iOS | 26.0 |
| Category | Education |
| Rating | 4+ |
