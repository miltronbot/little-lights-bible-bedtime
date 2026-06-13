# Bible Story Rewrite Spec (v2 content overhaul, June 2026)

Owner directive: make Scripture the heart of the app. Every one of the 50 stories is re-rooted in the Bible, quotes real verses, and is expanded to a richer bedtime length. This spec governs all 50 so they stay consistent.

## Source of truth
- Each story's `bibleReference` field names the passage. The retelling must be **faithful to that actual passage** — correct names, places, sequence of events, and details. Expand by going **deeper into the real account** (the current short text often covers only part of the passage), never by inventing events that aren't in Scripture.

## Length & tone
- **Target 550–750 words** of `storyText` per story (soft cap ~800). Consistent bedtime listening time (~5–6 min narration) matters more than a strict per-story multiplier.
- **Calm bedtime wind-down tone:** warm, gentle, reverent, unhurried. The current stories model the voice — keep it.
- Open with the setting → move through the biblical events with woven Scripture → land the heart/lesson → close with a gentle **second-person** good-night ("So tonight, little one, as you close your eyes…"). Address the listening child softly at the end.
- Paragraphs separated by `\n\n`. No headings inside storyText.

## Scripture (World English Bible)
- Weave **1–3 exact WEB verse quotations** into the narrative at key beats, in quotation marks, each followed by its reference in parentheses, e.g. `"…" (Genesis 9:13)`.
- **Every quoted verse MUST be fetched verbatim**, never quoted from memory:
  `curl -s "https://bible-api.com/genesis+9:13"` → returns WEB text in JSON (`.text`).
- **Divine name:** WEB renders the OT divine name as "Yahweh." In all quoted verses AND narrative prose, render it as **"the LORD"** (and "Yahweh's" → "the LORD's"). This is the only permitted change to fetched verse text (besides trimming with an ellipsis `…` when shortening a long verse).
- **`memoryVerse` field:** one short, memorable WEB verse (fetched), formatted exactly `"<verse text>" — <Book c:v>` (no translation tag in the field — WEB is credited once in the app's About/legal).

## Age-appropriateness (ages 3–12, bedtime)
- No graphic violence, gore, or fear. Handle hard moments the way the current stories do — gently and at a child's level (e.g. Goliath falls and the battle is won; the lions' mouths are shut; the cross is spoken of softly, with the empty tomb as joy). Never frightening at bedtime.
- Reverent and encouraging throughout; every story ends in comfort, safety, and God's love.

## Copy rules (PERMANENT owner directives — never violate)
- **Never** "hiding/hid God's Word in your heart" → say "learning by heart" / "keeping it in your heart" / "a missing word."
- **Never** the word "Affirmations" → say "Blessings."
- **Never** position Lumi (the firefly mascot) as false, wrong, or negative.

## Per-story fields to refresh (all of these)
- `storyText` — the expanded, Scripture-rooted retelling (above).
- `memoryVerse` — exact WEB key verse (above).
- `takeaway` — one gentle sentence naming the heart of the story.
- `bedtimePrayer` — a short child's prayer (2–3 sentences) that fits the story and ends restfully ("…help me sleep peacefully. Amen.").
- `talkAboutIt` — one warm parent-child question tied to the story's lesson (often gently referencing the verse).
- Do **not** change: `id`, `title`, `subtitle`, `bibleReference`, `category`, `isFree`, `imageName`, `audioFileName`, `narratorType`, `featuredCharacter`, `ageGroup`. (Durations are recomputed automatically after the rewrite.)

## Output contract (for drafting agents)
For each assigned story, write `/tmp/story-rewrites/<id>.json` containing:
```json
{
  "id": "<id>",
  "storyText": "…\n\n…",
  "memoryVerse": "\"…\" — Book c:v",
  "takeaway": "…",
  "bedtimePrayer": "…",
  "talkAboutIt": "…",
  "quotedVerses": [{"ref": "Genesis 9:13", "webTextUsed": "…"}]
}
```
`quotedVerses` lists every verse quoted (memory verse + woven quotes) with the exact fetched WEB text used, so accuracy can be re-verified.

## Audio (downstream, owner-run)
After the text lands, regenerate all 50 MP3s so narration matches: `python scripts/generate_audio.py` with an OpenAI key (~$3). Read-along stays in sync because it's proportional to playback length.
