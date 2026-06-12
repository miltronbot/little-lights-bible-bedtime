#!/usr/bin/env python3
"""
Generate audio narration files for Firefly Bible Bedtime stories using OpenAI's TTS API.

This script reads from stories.json and generates MP3 audio files for each story by combining:
- Story title introduction
- Story text
- Bedtime prayer

Audio files are saved to Resources/Audio/{audioFileName}.
"""

import argparse
import json
import logging
import os
import sys
from pathlib import Path
from typing import Optional
import time

try:
    from openai import OpenAI
except ImportError:
    print("Error: openai package not installed. Install with: pip install openai")
    sys.exit(1)


# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class StoryAudioGenerator:
    """Generate audio files for stories using OpenAI's TTS API."""

    # OpenAI TTS pricing: $15 per 1 million characters for tts-1-hd
    PRICING_PER_MILLION = 15.0

    # Configuration
    TTS_MODEL = "tts-1-hd"
    VOICE = "nova"  # Warm and soothing, good for children's bedtime stories

    def __init__(self, api_key: Optional[str] = None, dry_run: bool = False):
        """
        Initialize the generator.

        Args:
            api_key: OpenAI API key. If None, uses OPENAI_API_KEY environment variable.
            dry_run: If True, preview what would be generated without making API calls.
        """
        self.dry_run = dry_run

        if not dry_run:
            if not api_key:
                api_key = os.getenv("OPENAI_API_KEY")
            if not api_key:
                raise ValueError(
                    "OpenAI API key not provided. Set OPENAI_API_KEY environment variable "
                    "or pass --api-key argument."
                )
            self.client = OpenAI(api_key=api_key)
        else:
            self.client = None
            logger.info("DRY RUN MODE: No API calls will be made")

    def _build_narration(self, story: dict) -> str:
        """
        Combine story elements into a natural narration flow.

        Args:
            story: Story dictionary from stories.json

        Returns:
            Combined narration text
        """
        parts = []

        # Title introduction
        title = story.get("title", "")
        if title:
            parts.append(f"The story of {title}.")

        # Story text
        story_text = story.get("storyText", "")
        if story_text:
            parts.append(story_text)

        # Bedtime prayer
        prayer = story.get("bedtimePrayer", "")
        if prayer:
            parts.append(f"Bedtime prayer. {prayer}")

        return "\n\n".join(parts)

    def _estimate_cost(self, text: str) -> float:
        """
        Estimate cost for TTS of given text.

        Args:
            text: Text to estimate cost for

        Returns:
            Estimated cost in USD
        """
        char_count = len(text)
        return (char_count / 1_000_000) * self.PRICING_PER_MILLION

    def generate_story_audio(
        self,
        story: dict,
        output_dir: Path,
        retry_count: int = 3
    ) -> tuple[bool, str]:
        """
        Generate audio file for a single story.

        Args:
            story: Story dictionary from stories.json
            output_dir: Directory to save audio file
            retry_count: Number of times to retry on failure

        Returns:
            Tuple of (success: bool, message: str)
        """
        title = story.get("title", "Unknown")
        story_id = story.get("id", "unknown")
        audio_filename = story.get("audioFileName", f"{story_id}.mp3")

        # Build narration
        narration = self._build_narration(story)
        cost = self._estimate_cost(narration)

        if self.dry_run:
            logger.info(
                f"[DRY RUN] {title}\n"
                f"  ID: {story_id}\n"
                f"  Output: {audio_filename}\n"
                f"  Text length: {len(narration)} chars\n"
                f"  Estimated cost: ${cost:.4f}"
            )
            return True, f"Would generate audio for: {title}"

        # Generate audio with retry logic
        output_path = output_dir / audio_filename

        for attempt in range(1, retry_count + 1):
            try:
                logger.info(
                    f"Generating audio for: {title} "
                    f"({len(narration)} chars, ~${cost:.4f}) "
                    f"[Attempt {attempt}/{retry_count}]"
                )

                # Call OpenAI TTS API
                response = self.client.audio.speech.create(
                    model=self.TTS_MODEL,
                    voice=self.VOICE,
                    input=narration
                )

                # Save audio file
                with open(output_path, "wb") as f:
                    f.write(response.content)

                logger.info(f"✓ Saved: {audio_filename} ({output_path.stat().st_size:,} bytes)")
                return True, f"Generated audio for: {title}"

            except Exception as e:
                if attempt < retry_count:
                    wait_time = 2 ** (attempt - 1)  # Exponential backoff: 1s, 2s, 4s
                    logger.warning(
                        f"Attempt {attempt} failed for {title}: {str(e)}. "
                        f"Retrying in {wait_time}s..."
                    )
                    time.sleep(wait_time)
                else:
                    error_msg = f"Failed to generate audio for {title} after {retry_count} attempts: {str(e)}"
                    logger.error(error_msg)
                    return False, error_msg

        return False, f"Unknown error generating audio for: {title}"

    def generate_all_stories(
        self,
        stories_json_path: Path,
        output_dir: Path
    ) -> dict:
        """
        Generate audio files for all stories in stories.json.

        Args:
            stories_json_path: Path to stories.json
            output_dir: Directory to save audio files

        Returns:
            Dictionary with statistics: {
                'total': int,
                'successful': int,
                'failed': int,
                'estimated_cost': float,
                'failed_stories': list[dict]
            }
        """
        # Load stories
        with open(stories_json_path, 'r', encoding='utf-8') as f:
            stories = json.load(f)

        logger.info(f"Loaded {len(stories)} stories from {stories_json_path}")

        # Calculate total estimated cost
        total_chars = sum(
            len(s.get('storyText', '')) + len(s.get('bedtimePrayer', ''))
            for s in stories
        )
        estimated_cost = (total_chars / 1_000_000) * self.PRICING_PER_MILLION
        logger.info(
            f"Total characters: {total_chars:,} | "
            f"Estimated cost: ${estimated_cost:.2f}"
        )

        # Ensure output directory exists
        output_dir.mkdir(parents=True, exist_ok=True)

        # Generate audio for each story
        successful = 0
        failed = 0
        failed_stories = []

        for idx, story in enumerate(stories, 1):
            success, message = self.generate_story_audio(story, output_dir)

            # Progress bar
            progress = f"[{idx:2d}/{len(stories)}]"
            if success:
                successful += 1
                logger.info(f"{progress} ✓ {story.get('title', 'Unknown')}")
            else:
                failed += 1
                logger.error(f"{progress} ✗ {message}")
                failed_stories.append({
                    'id': story.get('id'),
                    'title': story.get('title'),
                    'error': message
                })

        # Summary
        logger.info("\n" + "="*70)
        logger.info("GENERATION COMPLETE")
        logger.info("="*70)
        logger.info(f"Total stories:     {len(stories)}")
        logger.info(f"Successful:        {successful}")
        logger.info(f"Failed:            {failed}")
        logger.info(f"Estimated cost:    ${estimated_cost:.2f}")
        logger.info("="*70)

        if failed_stories:
            logger.warning("\nFailed stories:")
            for story in failed_stories:
                logger.warning(f"  - {story['title']} ({story['id']})")

        return {
            'total': len(stories),
            'successful': successful,
            'failed': failed,
            'estimated_cost': estimated_cost,
            'failed_stories': failed_stories
        }

    def generate_single_story(
        self,
        stories_json_path: Path,
        output_dir: Path,
        story_id: str
    ) -> tuple[bool, str]:
        """
        Generate audio file for a single story by ID.

        Args:
            stories_json_path: Path to stories.json
            output_dir: Directory to save audio file
            story_id: ID of the story to generate

        Returns:
            Tuple of (success: bool, message: str)
        """
        # Load stories
        with open(stories_json_path, 'r', encoding='utf-8') as f:
            stories = json.load(f)

        # Find story by ID
        story = next((s for s in stories if s.get('id') == story_id), None)
        if not story:
            error_msg = f"Story with ID '{story_id}' not found"
            logger.error(error_msg)
            return False, error_msg

        # Ensure output directory exists
        output_dir.mkdir(parents=True, exist_ok=True)

        # Generate audio
        logger.info(f"Generating audio for single story: {story.get('title')}")
        success, message = self.generate_story_audio(story, output_dir)

        if success:
            logger.info(f"✓ {message}")
        else:
            logger.error(f"✗ {message}")

        return success, message


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Generate audio narration files for Firefly Bible Bedtime stories",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Generate audio for all stories
  python generate_audio.py

  # Dry run to preview without making API calls
  python generate_audio.py --dry-run

  # Generate audio for a single story
  python generate_audio.py --story noah-big-boat

  # Specify API key explicitly
  OPENAI_API_KEY=sk-xxx python generate_audio.py
        """
    )

    parser.add_argument(
        '--api-key',
        help='OpenAI API key (default: OPENAI_API_KEY env var)',
        default=None
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview what would be generated without making API calls'
    )
    parser.add_argument(
        '--story',
        help='Generate audio for a single story by ID',
        default=None
    )
    parser.add_argument(
        '--stories-json',
        type=Path,
        help='Path to stories.json',
        default=Path(__file__).parent.parent / 'Resources' / 'stories.json'
    )
    parser.add_argument(
        '--output-dir',
        type=Path,
        help='Output directory for audio files',
        default=Path(__file__).parent.parent / 'Resources' / 'Audio'
    )
    parser.add_argument(
        '--verbose',
        '-v',
        action='store_true',
        help='Enable verbose logging'
    )

    args = parser.parse_args()

    # Set log level
    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Validate paths
    if not args.stories_json.exists():
        logger.error(f"stories.json not found at: {args.stories_json}")
        sys.exit(1)

    try:
        # Create generator
        generator = StoryAudioGenerator(
            api_key=args.api_key,
            dry_run=args.dry_run
        )

        # Generate audio
        if args.story:
            success, message = generator.generate_single_story(
                args.stories_json,
                args.output_dir,
                args.story
            )
            sys.exit(0 if success else 1)
        else:
            result = generator.generate_all_stories(
                args.stories_json,
                args.output_dir
            )
            sys.exit(0 if result['failed'] == 0 else 1)

    except ValueError as e:
        logger.error(str(e))
        sys.exit(1)
    except KeyboardInterrupt:
        logger.warning("\nInterrupted by user")
        sys.exit(130)
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}", exc_info=True)
        sys.exit(1)


if __name__ == '__main__':
    main()
