# FireFly 2.0 — App Store Submission Steps

**Status when written (June 12, 2026):** v1.0 is **Waiting for Review** in App Store Connect. v2.0 is feature-complete on `main`. ASC name is set ("FireFly: Bible Bedtime Stories"). Listing copy is in `~/Desktop/AppStoreCopy/`; screenshots are in `~/Desktop/AppStoreScreenshots/`.

**Project facts (verified, nothing to change in code before archiving):**
- `MARKETING_VERSION = 2.0`, `CURRENT_PROJECT_VERSION = 1` (build 1)
- `ITSAppUsesNonExemptEncryption = NO` → no export-compliance prompt on upload
- `NSMicrophoneUsageDescription` + `NSPhotoLibraryAddUsageDescription` present in Info.plist
- Signing: team `ANY3QHU2YX`, automatic, Apple Distribution cert in keychain

---

## The key constraint

A never-released app **cannot have two versions in the review pipeline at once.** So you **cannot submit 2.0 while 1.0 is still "Waiting for Review."** Uploading the *build*, however, is independent of version records — so Part A can be done right now, in parallel, no matter which path you choose for Part B.

---

## Part A — Archive & upload the build (do now, safe regardless of the v1.0 decision)

1. **Open the project in Xcode**; sign in with your Apple ID (Settings → Accounts) if needed.
2. **Run destination** (top bar) → **"Any iOS Device (arm64)"**. (Can't archive against a simulator.)
3. **Product → Archive.** Wait for the build; the **Organizer** opens with the archive.
4. Organizer → select the archive → **Distribute App** → **App Store Connect** → **Upload** → accept defaults (automatic signing, include symbols) → **Upload**.
5. Wait for **"Upload Successful."** Build then shows **"Processing"** in ASC for ~5–30 min (email when ready).
   - If upload is rejected as a **duplicate build number**: bump `CURRENT_PROJECT_VERSION` to `2`, re-archive, re-upload.

**Optional but recommended — device QA via TestFlight.** Once the build finishes processing, install it on a real iPhone through TestFlight and verify the two things the simulator can't test (HANDOFF §6):
- Lock-screen Now Playing card + remote controls
- Parent Voice microphone recording

---

## Part B — Submit 2.0 (after v1.0 leaves the review queue)

### Path 1 — let v1.0 launch first (recommended)

Wait until v1.0 is **Approved**, release it, then:

1. ASC → your app → **"+ Version or Platform"** → enter **2.0** → Create.
2. Fill the 2.0 metadata from `~/Desktop/AppStoreCopy/`:
   - **What's New in This Version** ← `3-whats-new.txt` (required for updates)
   - **Description** ← `1-description.txt`
   - **Keywords** ← `2-keywords.txt`
   - **Support / Marketing URL** ← `4-urls.txt`
3. **Screenshots** — from `~/Desktop/AppStoreScreenshots/`:
   - `iPhone-6.9/` (1320×2868) → the 6.9" iPhone slot
   - `iPad-13/` (2064×2752) → the 13" iPad slot
   - Drag in `01 → 06` order (07-bedtime-routine optional). They're pre-numbered in display order; captions are in `docs/AppStoreListing.md` and `SCREENSHOTS_README.txt`.
4. **Build** section → **+** → select the processed 2.0 build.
5. **App Review Information** → paste `5-review-notes.txt` (explains mic / photo-add / iCloud / background-audio — the Kids-Category review-question pre-empt). No demo account needed (no login in the app).
6. **Version Release** → **"Manually release this version"** (control go-live timing).
7. Confirm age rating / category / privacy carried over from 1.0 → **Add for Review → Submit**.

### Path 2 — debut directly on 2.0

If you'd rather the first public version be 2.0:

1. **Remove v1.0 from review.**
2. On that same version record, change the version number to **2.0**.
3. Attach the 2.0 build; swap in the new copy + screenshots + review notes (steps 2–6 above).
4. Submit.

One review instead of two — trade-off is a slightly later launch and a bit more rejection surface (2.0 adds mic / photo / iCloud / Siri / background audio, all of which Kids-Category review scrutinizes).

---

## Which path?

With v1.0 still *Waiting for Review*, **do not remove it yet** — that's premature while the 2.0 build isn't even uploaded. Do **Part A now**, then decide Part B once the 2.0 build is processed and you can see whether v1.0 has been approved. Setting v1.0 to **manual release** keeps you in control either way: if it's approved before you're ready, it waits in "Pending Developer Release" instead of surprise-launching.

---

## Before-2.0-ships reminders (from HANDOFF §⭐ / §5)

- Suggest ~1 hour of trademark/terms attorney review before 2.0 ships.
- Listing copy + screenshots are current as of June 12, 2026. If more features land before submission, refresh `docs/AppStoreListing.md` and regenerate the two Desktop folders.
