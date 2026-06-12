# Audio Narration Generator - File Index

## Files in This Directory

### 1. **generate_audio.py** (Main Script)
The production-ready Python script that generates audio files.

**What it does:**
- Reads 50 stories from `../Resources/stories.json`
- Generates high-quality MP3 audio files using OpenAI's TTS API
- Saves files to `../Resources/Audio/`

**How to use:**
```bash
python generate_audio.py --help
```

**Key options:**
- `--dry-run` - Preview without making API calls
- `--story STORY_ID` - Generate one story by ID
- `--api-key KEY` - Provide OpenAI API key
- `--verbose` - Show detailed logging

**Requirements:**
- Python 3.6+
- OpenAI API key

### 2. **README.md** (Complete Documentation)
Comprehensive guide with everything you need to know.

**Covers:**
- Installation instructions
- API key setup
- Full usage examples
- Cost analysis
- Command-line options
- Free TTS alternatives
- Voice customization
- Troubleshooting

**Read this when:**
- Setting up for the first time
- Need detailed technical information
- Looking for alternative solutions
- Troubleshooting problems

### 3. **QUICKSTART.md** (Getting Started)
Quick reference guide for running the script.

**Covers:**
- 1-minute installation
- Basic usage examples
- Test procedures
- Cost verification

**Read this when:**
- First time running the script
- Need quick reference
- Want to test before committing costs

### 4. **INDEX.md** (This File)
Quick reference for all files in this directory.

## Quick Start

```bash
# 1. Install OpenAI
pip install openai

# 2. Set API key
export OPENAI_API_KEY='sk-...'

# 3. Test (free)
python generate_audio.py --dry-run

# 4. Generate one story (test)
python generate_audio.py --story noah-big-boat

# 5. Generate all 50 stories
python generate_audio.py
```

## Cost
- **Total for all 50 stories:** ~$0.96
- **Per story average:** $0.019

## Output
All audio files saved to: `../Resources/Audio/`

## Need Help?

1. **For installation:** See QUICKSTART.md or README.md
2. **For usage:** Run `python generate_audio.py --help`
3. **For troubleshooting:** Check README.md Troubleshooting section
4. **For alternatives:** See README.md "Free TTS Alternatives" section

## Key Story IDs

Some story examples for `--story` flag:
- noah-big-boat
- daniel-and-the-lions
- jesus-calms-the-storm
- the-lost-sheep
- the-birth-of-jesus
- david-and-goliath

Run `python generate_audio.py --dry-run` to see all 50 story IDs.

## Features

✓ High-quality audio (tts-1-hd model)
✓ Natural voice ("nova" - warm and soothing)
✓ Automatic retry on failure
✓ Progress tracking
✓ Cost estimation
✓ Single story or batch generation
✓ Preview mode without API calls

---

Generated for FireFly: Bible Bedtime Stories audio narration project.
