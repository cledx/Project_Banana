#!/usr/bin/env python3
"""
generate_recipe_images.py

One-time script that:
  1. Reads recipesV3.json
  2. Generates a photo-realistic image for each recipe via DALL-E 3
  3. Saves each image to app/assets/images/recipe_images/
  4. Writes a new recipesV3_with_images.json with an `image_url` field per recipe

Usage:
    pip install openai requests
    python generate_recipe_images.py --api-key YOUR_OPENAI_KEY

Alternatively, set the OPENAI_API_KEY environment variable and omit --api-key.
"""

import argparse
import json
import os
import re
import sys
import time
import requests
from pathlib import Path
from openai import OpenAI

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

INPUT_JSON = "recipesV3.json"
OUTPUT_JSON = "recipesV3_with_images.json"

# Relative to your Rails root — adjust if running from a different directory.
# The script will create this directory if it doesn't exist.
OUTPUT_IMAGE_DIR = Path("app/assets/images/recipe_images")

# The relative URL that Rails will resolve at runtime.
IMAGE_URL_PREFIX = "/assets/recipe_images"

# DALL-E 3 settings
IMAGE_SIZE = "1024x1024"
IMAGE_QUALITY = "standard"   # "standard" or "hd" — hd costs 2x but is sharper
IMAGE_MODEL = "dall-e-3"

# Retry settings — the API occasionally rate-limits on burst requests.
MAX_RETRIES = 3
RETRY_DELAY = 10  # seconds between retries

# ---------------------------------------------------------------------------
# Setting pool — cycled through to give each recipe a distinct environment.
# ---------------------------------------------------------------------------

SETTINGS = [
    "on a rustic wooden dining table at home, warm kitchen light",
    "on a white marble countertop in a modern home kitchen",
    "served in a cosy café with exposed brick walls and warm pendant lighting",
    "plated elegantly in an upscale restaurant with soft candlelight",
    "on a picnic blanket outdoors in afternoon sunlight",
    "on a farmhouse kitchen table with a linen napkin beside it",
    "in a bright Scandinavian-style kitchen, natural daylight from a window",
    "on a dark slate surface in a moody, fine-dining restaurant setting",
    "in a busy city café, shallow depth of field, blurred background",
    "on a wooden breakfast tray beside a window with morning light",
    "on a colourful tiled surface in a Mediterranean-style kitchen",
    "on a chef's stainless-steel prep counter in a professional kitchen",
]


def slugify(name: str) -> str:
    """Convert a recipe name to a safe, lowercase filename slug."""
    name = name.lower()
    name = re.sub(r"[^a-z0-9]+", "_", name)
    name = name.strip("_")
    return name


def build_prompt(recipe: dict, setting: str) -> str:
    """
    Build a DALL-E prompt that describes the dish in a specific setting.
    Keeping prompts concrete and food-focused yields the most realistic results.
    """
    name = recipe["name"]
    cuisine = recipe.get("cuisine", "")
    category = recipe.get("category", "")

    # Pull the first 3 ingredient names for extra visual specificity
    ingredients = recipe.get("ingredients", [])
    top_ingredients = ", ".join(i["name"] for i in ingredients[:3]) if ingredients else ""

    prompt = (
        f"A professional food photography shot of {name}, "
        f"a {cuisine} {category} dish"
        f"{f' featuring {top_ingredients}' if top_ingredients else ''}. "
        f"The meal is {setting}. "
        "Photorealistic, high resolution, appetising, "
        "shallow depth of field, natural colours, no text or watermarks."
    )
    return prompt


def generate_image(client: OpenAI, prompt: str, recipe_name: str) -> bytes | None:
    """Call DALL-E 3 and return the raw image bytes, or None on failure."""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            response = client.images.generate(
                model=IMAGE_MODEL,
                prompt=prompt,
                size=IMAGE_SIZE,
                quality=IMAGE_QUALITY,
                n=1,
            )
            image_url = response.data[0].url
            img_response = requests.get(image_url, timeout=60)
            img_response.raise_for_status()
            return img_response.content

        except Exception as exc:
            print(f"    ⚠  Attempt {attempt}/{MAX_RETRIES} failed for '{recipe_name}': {exc}")
            if attempt < MAX_RETRIES:
                print(f"    ↻  Retrying in {RETRY_DELAY}s…")
                time.sleep(RETRY_DELAY)
            else:
                print(f"    ✗  Giving up on '{recipe_name}'. Skipping image.")
                return None


def main():
    parser = argparse.ArgumentParser(description="Generate recipe images via DALL-E 3.")
    parser.add_argument("--api-key", help="OpenAI API key (or set OPENAI_API_KEY env var)")
    parser.add_argument("--input",   default=INPUT_JSON,  help=f"Input JSON path (default: {INPUT_JSON})")
    parser.add_argument("--output",  default=OUTPUT_JSON, help=f"Output JSON path (default: {OUTPUT_JSON})")
    parser.add_argument("--image-dir", default=str(OUTPUT_IMAGE_DIR),
                        help=f"Directory to save images (default: {OUTPUT_IMAGE_DIR})")
    parser.add_argument("--skip-existing", action="store_true",
                        help="Skip image generation if the file already exists (useful for reruns)")
    args = parser.parse_args()

    # --- API key ---
    api_key = args.api_key or os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("Error: No OpenAI API key provided. Use --api-key or set OPENAI_API_KEY.")
        sys.exit(1)

    client = OpenAI(api_key=api_key)

    # --- Load JSON ---
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: Input file not found: {input_path}")
        sys.exit(1)

    with open(input_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    recipes = data.get("data", [])
    print(f"✔  Loaded {len(recipes)} recipes from {input_path}")

    # --- Prepare output image directory ---
    image_dir = Path(args.image_dir)
    image_dir.mkdir(parents=True, exist_ok=True)
    print(f"✔  Image output directory: {image_dir.resolve()}")

    # --- Generate images ---
    updated_recipes = []

    for index, recipe in enumerate(recipes):
        name = recipe.get("name", f"recipe_{index}")
        slug = slugify(name)
        filename = f"{slug}.png"
        file_path = image_dir / filename
        image_url = f"{IMAGE_URL_PREFIX}/{filename}"

        setting = SETTINGS[index % len(SETTINGS)]

        print(f"\n[{index + 1}/{len(recipes)}] {name}")
        print(f"    Setting : {setting}")
        print(f"    Filename: {filename}")

        if args.skip_existing and file_path.exists():
            print(f"    ↷  File already exists — skipping generation.")
        else:
            prompt = build_prompt(recipe, setting)
            print(f"    Prompt  : {prompt[:120]}…")

            image_bytes = generate_image(client, prompt, name)

            if image_bytes:
                with open(file_path, "wb") as img_file:
                    img_file.write(image_bytes)
                print(f"    ✔  Saved → {file_path}")
            else:
                # Leave image_url in the JSON even if generation failed,
                # so the field is consistent; the file just won't exist yet.
                print(f"    ✗  No image saved for this recipe.")

        updated_recipe = dict(recipe)
        updated_recipe["image_url"] = image_url
        updated_recipes.append(updated_recipe)

        # Small polite pause between requests to avoid rate-limit bursts.
        # DALL-E 3 allows 5 images/min on standard tier.
        if index < len(recipes) - 1:
            time.sleep(13)

    # --- Write output JSON ---
    output_data = dict(data)
    output_data["data"] = updated_recipes

    output_path = Path(args.output)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output_data, f, indent=2, ensure_ascii=False)

    print(f"\n✔  Done. Updated JSON written to: {output_path.resolve()}")
    print(f"   {len(updated_recipes)} recipes, each with an `image_url` field.")


if __name__ == "__main__":
    main()
