# Games Hub — Midjourney Artwork Prompts

The Games hub is wired to show painted artwork tiles in the same style as the
story cards. The app looks for these asset names in `Assets.xcassets` and
falls back to the current icon tiles until each image exists — so you can add
them one at a time.

## How to add (same pipeline as the story art)

1. Generate each prompt below in Midjourney (square `--ar 1:1`).
2. Pick the best panel from the 2x2 grid and crop it to one square image.
3. In Xcode: Assets.xcassets → New Image Set → name it EXACTLY as listed →
   drop the image into the 1x slot.
4. Build — the Games hub picks it up automatically. No code changes needed.

Shared style tail for every prompt (keeps them matched to the story art):

> `children's storybook illustration, soft painted style, warm golden glow
> against a deep twilight blue night sky, gentle and cozy, no text,
> no words, no letters --ar 1:1`

## The eight tiles

| Asset name | Prompt (add the style tail above) |
|---|---|
| `game-story-quiz` | A glowing golden question mark made of starlight floating above an open storybook at night, tiny stars swirling around it |
| `game-who-am-i` | A friendly silhouette of a shepherd holding a staff behind a soft glowing curtain of stars, mysterious but warm |
| `game-lumis-true-or-false` | A cute glowing firefly with a warm yellow lantern light hovering between a green checkmark of fireflies and the moon |
| `game-guess-the-story` | A framed painting of a starry Bible scene half-hidden behind soft drifting fog, golden light peeking through |
| `game-treasure-match` | Pairs of small glowing treasure cards laid on deep blue velvet under starlight, one pair flipped to show matching golden stars |
| `game-story-scramble` | Four small glowing storybook pages floating in a gentle spiral under the night sky, stardust trailing between them |
| `game-verse-builder` | Softly glowing word tiles made of golden light being stacked by tiny fireflies into a sentence under the stars |
| `game-verse-practice` | An open Bible glowing warmly on a windowsill at night with a child's teddy bear beside it, moonlight through the window |

Keep every image gentle and child-friendly: no scary shapes, no sharp
contrast, faces (if any) soft and kind — same rules as the story artwork.
