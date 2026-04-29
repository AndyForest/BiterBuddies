#!/usr/bin/env tsx
/**
 * Center-crops thumbnail_v2.png to a square Factorio mod-portal thumbnail.
 * Output: thumbnail.png at 1024x1024 (bundled with the zip).
 *
 * Usage: npx tsx scripts/make-thumbnail.ts
 */

import path from "path";
import sharp from "sharp";

const ROOT = path.join(__dirname, "..");
const SOURCE = path.join(ROOT, "thumbnail_v2.png");
const TARGET = path.join(ROOT, "thumbnail.png");
// 512px square fits comfortably under the mod portal's 1 MiB thumbnail size cap
// while still rendering crisp on the portal's larger preview view.
const SIZE = 512;

async function main(): Promise<void> {
  const meta = await sharp(SOURCE).metadata();
  const { width, height } = meta;
  if (!width || !height) throw new Error(`No dimensions for ${SOURCE}`);

  const cropSize = Math.min(width, height);
  const left = Math.floor((width - cropSize) / 2);
  const top = Math.floor((height - cropSize) / 2);

  await sharp(SOURCE)
    .extract({ left, top, width: cropSize, height: cropSize })
    .resize(SIZE, SIZE)
    .png({ compressionLevel: 9 })
    .toFile(TARGET);

  const out = await sharp(TARGET).metadata();
  console.log(
    `Wrote ${path.relative(ROOT, TARGET)}: ${out.width}x${out.height} (cropped from ${width}x${height} center, offset left=${left} top=${top})`
  );
}

main();
