# Audio Narration Handoff — ElevenLabs Generation Session
**Date:** April 14, 2026  
**Status:** ✅ Complete — 50/50 stories generated and bundled

---

## What Was Done
All 50 story narrations were pre-generated via ElevenLabs API and saved as MP3s
directly into `Resources/Audio/`. The app is fully offline — no API key required
at runtime. ElevenLabs is no longer needed as a fallback.

---

## Voice Assignment (by category)

| Voice | ElevenLabs ID | Categories |
|-------|--------------|------------|
| **Brian** | `nPczCjzI2devNBz1zQrb` | Trust, Courage, Hope |
| **Sarah** | `EXAVITQu4vr4xnSDxMaL` | Love, Peace, Prayer, Kindness |

---

## Audio Stats
- Total stories: 50/50
- Total audio size: 53 MB
- Smallest file: 398 KB
- Largest file: 2,211 KB
- Model used: `eleven_monolingual_v1`
- Voice settings: stability 0.75, similarity_boost 0.75

---

## Story → Voice Map

| # | Story | Category | Voice |
|---|-------|----------|-------|
| 01 | Noah and the Big Boat | Trust | Brian |
| 02 | Daniel and the Lions | Courage | Brian |
| 03 | Jesus Calms the Storm | Peace | Sarah |
| 04 | The Lost Sheep | Love | Sarah |
| 05 | The Birth of Jesus | Hope | Brian |
| 06 | David and Goliath | Courage | Brian |
| 07 | Jonah and the Big Fish | Trust | Brian |
| 08 | Baby Moses | Hope | Brian |
| 09 | The Good Samaritan | Kindness | Sarah |
| 10 | Creation Story | Hope | Brian |
| 11 | Joseph and His Colorful Coat | Hope | Brian |
| 12 | The Wise Men | Hope | Brian |
| 13 | Christmas: The Birth of Jesus | Peace | Sarah |
| 14 | Zacchaeus | Love | Sarah |
| 15 | Feeding the Five Thousand | Trust | Brian |
| 16 | Jesus Loves the Children | Love | Sarah |
| 17 | The Prodigal Son | Love | Sarah |
| 18 | Esther's Courage | Courage | Brian |
| 19 | Joshua and Jericho | Trust | Brian |
| 20 | Elijah and the Whisper | Peace | Sarah |
| 21 | The Boy Samuel | Prayer | Sarah |
| 22 | Abraham and the Stars | Trust | Brian |
| 23 | Ruth and Naomi | Kindness | Sarah |
| 24 | Moses and the Burning Bush | Courage | Brian |
| 25 | The Walls of Water | Trust | Brian |
| 26 | Jacob's Ladder Dream | Hope | Brian |
| 27 | Gideon's Brave 300 | Courage | Brian |
| 28 | Elijah and the Ravens | Trust | Brian |
| 29 | Shadrach, Meshach, and Abednego | Courage | Brian |
| 30 | Hannah's Prayer | Prayer | Sarah |
| 31 | The Garden of Eden | Love | Sarah |
| 32 | Joseph Forgives His Brothers | Kindness | Sarah |
| 33 | Miriam's Song | Hope | Brian |
| 34 | Nehemiah Builds the Wall | Courage | Brian |
| 35 | David the Shepherd Boy | Peace | Sarah |
| 36 | Solomon Asks for Wisdom | Prayer | Sarah |
| 37 | Jesus Walks on Water | Trust | Brian |
| 38 | The Mustard Seed | Hope | Brian |
| 39 | Jesus Heals the Blind Man | Love | Sarah |
| 40 | The Sower and the Seeds | Hope | Brian |
| 41 | Mary and Martha | Peace | Sarah |
| 42 | The Ten Lepers | Prayer | Sarah |
| 43 | Jesus in the Garden of Gethsemane | Prayer | Sarah |
| 44 | The Empty Tomb | Hope | Brian |
| 45 | Peter Walks on Water | Courage | Brian |
| 46 | The Widow's Offering | Kindness | Sarah |
| 47 | Jesus and the Woman at the Well | Love | Sarah |
| 48 | The Talents | Trust | Brian |
| 49 | Jesus Washes the Disciples' Feet | Kindness | Sarah |
| 50 | The Light of the World | Peace | Sarah |

---

## Important Notes
- ElevenLabs Creator plan ($22/month) was used for generation — can be cancelled
- Commercial usage rights covered under ElevenLabs Creator plan
- The `ElevenLabsService.swift` fallback remains in code but will never trigger
  since all bundled MP3s now exist
- If regeneration is ever needed, use voice IDs above with `eleven_monolingual_v1`
- Do NOT use the free tier — API access requires paid plan
