# Audio Narration Generator

Generate high-quality audio narration files for all 50 FireFly: Bible Bedtime Stories stories using OpenAI's TTS API.

## Quick Start

### 1. Install Dependencies

```bash
pip install openai
```

### 2. Set Your OpenAI API Key

```bash
export OPENAI_API_KEY='sk-your-api-key-here'
```

Or pass it directly:

```bash
python generate_audio.py --api-key sk-your-api-key-here
```

### 3. Generate Audio Files

**Generate audio for all 50 stories:**

```bash
python generate_audio.py
```

**Preview without making API calls (dry run):**

```bash
python generate_audio.py --dry-run
```

**Generate audio for a single story:**

```bash
python generate_audio.py --story noah-big-boat
```

## How It Works

The script:

1. **Reads** `stories.json` and extracts:
   - Story title
   - Story text
   - Bedtime prayer

2. **Combines** the text naturally:
   - "The story of [Title]."
   - [Full story text]
   - "Bedtime prayer. [Prayer]"

3. **Generates** high-quality audio using OpenAI's TTS API:
   - **Model:** `tts-1-hd` (highest quality)
   - **Voice:** `nova` (warm and soothing, perfect for children's bedtime stories)

4. **Saves** MP3 files to `Resources/Audio/{audioFileName}`

5. **Handles errors gracefully** with automatic retry logic (3 attempts with exponential backoff)

## Cost Estimation

- **Total characters:** ~64,000 (all 50 stories)
- **OpenAI TTS pricing:** $15 per 1 million characters (tts-1-hd)
- **Estimated total cost:** **~$0.96** for all 50 stories

This is very affordable for professional-quality audio narration!

## Command-Line Options

```
usage: generate_audio.py [-h] [--api-key API_KEY] [--dry-run] [--story STORY]
                         [--stories-json STORIES_JSON] [--output-dir OUTPUT_DIR]
                         [--verbose]

Generate audio narration files for FireFly: Bible Bedtime Stories stories

options:
  -h, --help                    Show this help message
  --api-key API_KEY             OpenAI API key (default: OPENAI_API_KEY env var)
  --dry-run                     Preview what would be generated without API calls
  --story STORY                 Generate audio for a single story by ID
  --stories-json STORIES_JSON   Path to stories.json
  --output-dir OUTPUT_DIR       Output directory for audio files
  --verbose, -v                 Enable verbose logging
```

## Examples

### Generate all stories with progress tracking

```bash
OPENAI_API_KEY='sk-xxx' python generate_audio.py
```

Output:
```
2026-03-25 10:30:15 - INFO - Loaded 50 stories from stories.json
2026-03-25 10:30:15 - INFO - Total characters: 64,322 | Estimated cost: $0.96
2026-03-25 10:30:16 - INFO - [ 1/50] ✓ Noah and the Big Boat
2026-03-25 10:30:17 - INFO - [ 2/50] ✓ Daniel and the Lions
...
2026-03-25 10:35:42 - INFO - [50/50] ✓ The Prodigal Son Returns Home
2026-03-25 10:35:43 - INFO - ======================================================================
2026-03-25 10:35:43 - INFO - GENERATION COMPLETE
2026-03-25 10:35:43 - INFO - ======================================================================
2026-03-25 10:35:43 - INFO - Total stories:     50
2026-03-25 10:35:43 - INFO - Successful:        50
2026-03-25 10:35:43 - INFO - Failed:            0
2026-03-25 10:35:43 - INFO - Estimated cost:    $0.96
```

### Preview without making API calls

```bash
python generate_audio.py --dry-run
```

Output:
```
2026-03-25 10:30:15 - INFO - DRY RUN MODE: No API calls will be made
2026-03-25 10:30:15 - INFO - [DRY RUN] Noah and the Big Boat
  ID: noah-big-boat
  Output: noah_big_boat.mp3
  Text length: 2789 chars
  Estimated cost: $0.0418
2026-03-25 10:30:15 - INFO - [DRY RUN] Daniel and the Lions
  ...
```

### Generate audio for one story

```bash
python generate_audio.py --story daniel-and-the-lions
```

## Free TTS Alternatives

If you prefer not to use OpenAI's TTS API, here are some free alternatives:

### 1. Apple's `say` Command (macOS only)

Simple, native, no cost. Voices are less modern but functional.

```bash
say -v "Samantha" -r 120 -f text.txt -o output.aiff
```

**Pros:** Free, no API key needed, native quality
**Cons:** macOS only, limited voice options, lower quality

### 2. edge-tts (Free, cross-platform)

Uses Microsoft Edge's TTS engine. Good quality, supports many languages and voices.

```bash
pip install edge-tts
edge-tts --voice en-US-AriaNeural --text "Your text here" --write-media output.mp3
```

**Pros:** Free, cross-platform, modern voices, good quality
**Cons:** Third-party tool (may change availability), slightly lower quality than OpenAI

### 3. pyttsx3 (Free, offline, cross-platform)

Pure Python TTS engine. Works offline, no API key needed.

```bash
pip install pyttsx3
```

**Pros:** Free, offline, works everywhere, no API key
**Cons:** Lower audio quality, more robotic sounding

### 4. Google Text-to-Speech (Free tier)

Free for ~500K characters/month. Good quality, supports many languages.

**Pros:** Free tier is generous, good quality
**Cons:** Free tier limits, requires Google Cloud account

## Setup for Free TTS

To use a free alternative, you would need to:

1. Modify the script to use that TTS provider instead of OpenAI
2. Add the appropriate dependency
3. Update the voice/quality settings

Here's a minimal example for edge-tts (would require script modification):

```python
import edge_tts

async def generate_audio_edge_tts(text, output_file):
    communicate = edge_tts.Communicate(text=text, voice="en-US-AriaNeural")
    await communicate.save(output_file)
```

## Troubleshooting

### "OpenAI API key not provided"

Make sure you set the `OPENAI_API_KEY` environment variable:

```bash
export OPENAI_API_KEY='sk-your-key'
python generate_audio.py
```

### "stories.json not found"

Make sure you're running the script from the `scripts/` directory or provide the full path:

```bash
python generate_audio.py --stories-json /path/to/stories.json
```

### Retry failures

If you see "Attempt X failed" messages, the script will automatically retry up to 3 times with exponential backoff. This is normal for API rate limiting or temporary network issues.

### Permission denied saving files

Make sure the `Resources/Audio/` directory exists and is writable:

```bash
mkdir -p Resources/Audio
chmod 755 Resources/Audio
```

## Output Files

Generated audio files are saved to:
```
Resources/Audio/
├── noah_big_boat.mp3
├── daniel_and_the_lions.mp3
├── jesus_calms_the_storm.mp3
└── ... (50 total)
```

Each file corresponds to the `audioFileName` field in `stories.json`.

## OpenAI TTS API Documentation

For more information about OpenAI's TTS API:
- https://platform.openai.com/docs/guides/text-to-speech
- https://platform.openai.com/account/billing/overview (check your usage and costs)

## Voice Options in OpenAI TTS

The script uses the `nova` voice, which is warm and soothing. Other available voices:

- `alloy` - Neutral, helpful tone
- `echo` - Smooth, expressive
- `fable` - Storyteller-like, warm
- `onyx` - Deep, bold
- `shimmer` - Bright, energetic
- `nova` - **Recommended** - Warm, natural, soothing (current)

To change the voice, modify the `VOICE` constant in the script:

```python
VOICE = "nova"  # Change this to another voice
```

## License

This script is part of the FireFly: Bible Bedtime Stories app.
