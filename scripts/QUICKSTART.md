# Quick Start Guide

## Installation (1 minute)

```bash
pip install openai
```

## Get Your OpenAI API Key

1. Go to https://platform.openai.com/account/api-keys
2. Create a new secret key
3. Copy it (it won't be shown again)

## Run the Script

### Option 1: Set environment variable (recommended)

```bash
export OPENAI_API_KEY='sk-your-api-key-here'
python scripts/generate_audio.py
```

### Option 2: Pass API key directly

```bash
python scripts/generate_audio.py --api-key sk-your-api-key-here
```

## Test First (Free)

Before spending money, preview what will be generated:

```bash
python scripts/generate_audio.py --dry-run
```

This shows what text will be converted to speech without making any API calls.

## Generate One Story (Test)

Generate audio for just one story to test quality:

```bash
python scripts/generate_audio.py --story noah-big-boat
```

Check the output at `Resources/Audio/noah_big_boat.mp3`

## Generate All 50 Stories

```bash
python scripts/generate_audio.py
```

Expected:
- Runtime: ~5-10 minutes (depends on API response times)
- Cost: ~$0.96
- Files: 50 MP3 files in `Resources/Audio/`

## What Gets Generated

Each story file includes:
1. Story title introduction (e.g., "The story of Noah and the Big Boat")
2. Full story text
3. Bedtime prayer

All combined with natural pauses between sections.

## Troubleshooting

**"API key not found"**
```bash
export OPENAI_API_KEY='sk-...'
```

**"stories.json not found"**
Make sure you're in the right directory:
```bash
cd /path/to/LittleLightsBibleBedtime
python scripts/generate_audio.py
```

**"Permission denied saving files"**
```bash
mkdir -p Resources/Audio
chmod 755 Resources/Audio
```

## Cost Check

Before running, you can calculate cost:

```bash
python scripts/generate_audio.py --dry-run
```

Look for: "Estimated cost: $X.XX"

## Voice Customization

The script uses "nova" voice (warm, soothing). To change it:

Edit `scripts/generate_audio.py` and change line 45:
```python
VOICE = "nova"  # Change to: "alloy", "echo", "fable", "onyx", or "shimmer"
```

## Available Story IDs

Some example story IDs for --story flag:
- noah-big-boat
- daniel-and-the-lions
- jesus-calms-the-storm
- the-lost-sheep
- the-birth-of-jesus
- david-and-goliath

Run `python scripts/generate_audio.py --dry-run` to see all 50 story IDs.

## Success!

Once complete, you'll have 50 professional-quality MP3 audio files in `Resources/Audio/` ready to use in your app!
