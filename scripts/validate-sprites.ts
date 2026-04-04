#!/usr/bin/env tsx
/**
 * Validates that all sprite/icon references in data.lua match actual image dimensions.
 * Reads FACTORIO_PATH from .env to resolve __base__ paths.
 *
 * Usage: npx tsx scripts/validate-sprites.ts
 */

import fs from "fs";
import path from "path";
import sharp from "sharp";

interface SpriteRef {
  file: string;
  width: number;
  height: number;
  frame_count: number | null;
  line_length: number | null;
  line: number;
}

interface IconRef {
  file: string;
  line: number;
}

interface ImageDimensions {
  width: number;
  height: number;
}

function loadEnv(): Record<string, string> {
  const envPath = path.join(__dirname, "..", ".env");
  if (!fs.existsSync(envPath)) {
    console.error("ERROR: .env file not found. Copy .env.example to .env and set FACTORIO_PATH.");
    process.exit(1);
  }
  const lines = fs.readFileSync(envPath, "utf8").split("\n");
  const env: Record<string, string> = {};
  for (const line of lines) {
    const match = line.match(/^([^=]+)=(.*)$/);
    if (match) env[match[1].trim()] = match[2].trim();
  }
  return env;
}

function resolveFactorioPath(filename: string, factorioPath: string): string {
  return filename.replace("__base__", path.join(factorioPath, "data", "base"));
}

function findSpriteRefs(dataLua: string): SpriteRef[] {
  const refs: SpriteRef[] = [];
  const lines = dataLua.split("\n");

  let current: Partial<SpriteRef> | null = null;

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const lineNum = i + 1;

    const fileMatch = line.match(/filename\s*=\s*"([^"]+)"/);
    if (fileMatch) {
      if (current?.file && current.width && current.height) {
        refs.push(current as SpriteRef);
      }
      current = {
        file: fileMatch[1],
        width: undefined,
        height: undefined,
        frame_count: null,
        line_length: null,
        line: lineNum,
      };
    }

    if (!current) continue;

    const widthMatch = line.match(/^\s*width\s*=\s*(\d+)/);
    if (widthMatch) current.width = parseInt(widthMatch[1]);

    const heightMatch = line.match(/^\s*height\s*=\s*(\d+)/);
    if (heightMatch) current.height = parseInt(heightMatch[1]);

    const fcMatch = line.match(/frame_count\s*=\s*(\d+)/);
    if (fcMatch) current.frame_count = parseInt(fcMatch[1]);

    const llMatch = line.match(/line_length\s*=\s*(\d+)/);
    if (llMatch) current.line_length = parseInt(llMatch[1]);
  }

  if (current?.file && current.width && current.height) {
    refs.push(current as SpriteRef);
  }

  return refs;
}

function findIconRefs(dataLua: string): IconRef[] {
  const refs: IconRef[] = [];
  const lines = dataLua.split("\n");
  for (let i = 0; i < lines.length; i++) {
    const match = lines[i].match(/icon\s*=\s*"([^"]+\.png)"\s*,/);
    // Skip dynamically constructed Lua paths (contain .. concatenation)
    if (match && !lines[i].includes("..")) {
      refs.push({ file: match[1], line: i + 1 });
    }
  }
  return refs;
}

async function getImageDimensions(filePath: string): Promise<ImageDimensions> {
  const metadata = await sharp(filePath).metadata();
  if (!metadata.width || !metadata.height) {
    throw new Error(`Could not read dimensions from ${filePath}`);
  }
  return { width: metadata.width, height: metadata.height };
}

async function validateSpriteRef(
  ref: SpriteRef,
  factorioPath: string
): Promise<string[]> {
  const resolved = resolveFactorioPath(ref.file, factorioPath);
  const errors: string[] = [];

  if (!fs.existsSync(resolved)) {
    errors.push(`File not found: ${resolved}`);
    return errors;
  }

  const actual = await getImageDimensions(resolved);
  const lineLength = ref.line_length ?? ref.frame_count ?? 1;
  const frameCount = ref.frame_count ?? 1;
  const rows = Math.ceil(frameCount / lineLength);

  const requiredWidth = ref.width * lineLength;
  const requiredHeight = ref.height * rows;

  if (requiredWidth > actual.width) {
    const maxPerRow = Math.floor(actual.width / ref.width);
    errors.push(
      `Width overflow: ${lineLength} frames * ${ref.width}px = ${requiredWidth}px, ` +
        `but image is ${actual.width}px wide (max line_length=${maxPerRow})`
    );
  }

  if (requiredHeight > actual.height) {
    const maxRows = Math.floor(actual.height / ref.height);
    errors.push(
      `Height overflow: ${rows} rows * ${ref.height}px = ${requiredHeight}px, ` +
        `but image is ${actual.height}px tall (max ${maxRows} rows)`
    );
  }

  if (actual.width % ref.width !== 0) {
    errors.push(
      `Image width ${actual.width} not evenly divisible by frame width ${ref.width}`
    );
  }

  if (actual.height % ref.height !== 0) {
    errors.push(
      `Image height ${actual.height} not evenly divisible by frame height ${ref.height}`
    );
  }

  return errors;
}

async function main(): Promise<void> {
  const env = loadEnv();
  const factorioPath = env.FACTORIO_PATH;

  if (!factorioPath || !fs.existsSync(factorioPath)) {
    console.error(`ERROR: FACTORIO_PATH does not exist: ${factorioPath}`);
    process.exit(1);
  }

  const dataLuaPath = path.join(__dirname, "..", "data.lua");
  const dataLua = fs.readFileSync(dataLuaPath, "utf8");

  let hasErrors = false;

  // --- Sprite sheets ---
  console.log("=== Sprite Sheet Validation ===\n");

  const spriteRefs = findSpriteRefs(dataLua);
  for (const ref of spriteRefs) {
    const resolved = resolveFactorioPath(ref.file, factorioPath);
    const errors = await validateSpriteRef(ref, factorioPath);

    if (errors.length > 0) {
      hasErrors = true;
      console.log(`FAIL  data.lua:${ref.line}  ${ref.file}`);
      console.log(
        `      Declared: ${ref.width}x${ref.height}, frame_count=${ref.frame_count}, line_length=${ref.line_length}`
      );
      if (fs.existsSync(resolved)) {
        const actual = await getImageDimensions(resolved);
        console.log(`      Actual image: ${actual.width}x${actual.height}`);
      }
      for (const err of errors) {
        console.log(`      ${err}`);
      }
      console.log();
    } else {
      const actual = await getImageDimensions(resolved);
      const lineLength = ref.line_length ?? ref.frame_count ?? 1;
      const rows = Math.ceil((ref.frame_count ?? 1) / lineLength);
      console.log(`OK    data.lua:${ref.line}  ${ref.file}`);
      console.log(
        `      ${actual.width}x${actual.height} -> ${lineLength} cols x ${rows} rows of ${ref.width}x${ref.height} frames`
      );
    }
  }

  // --- Icons ---
  console.log("\n=== Icon File Validation ===\n");

  const iconRefs = findIconRefs(dataLua);
  for (const ref of iconRefs) {
    const resolved = resolveFactorioPath(ref.file, factorioPath);

    if (!fs.existsSync(resolved)) {
      hasErrors = true;
      console.log(`FAIL  data.lua:${ref.line}  ${ref.file}`);
      console.log(`      File not found: ${resolved}`);
      continue;
    }

    const stat = fs.statSync(resolved);
    if (stat.isDirectory()) {
      hasErrors = true;
      console.log(`FAIL  data.lua:${ref.line}  ${ref.file}`);
      console.log(`      Path is a directory, not a file`);
      continue;
    }

    try {
      const dims = await getImageDimensions(resolved);
      console.log(
        `OK    data.lua:${ref.line}  ${ref.file}  (${dims.width}x${dims.height})`
      );
    } catch (e) {
      hasErrors = true;
      console.log(`FAIL  data.lua:${ref.line}  ${ref.file}`);
      console.log(`      Error: ${(e as Error).message}`);
    }
  }

  console.log();
  if (hasErrors) {
    console.log("VALIDATION FAILED — fix errors above before loading in Factorio.");
    process.exit(1);
  } else {
    console.log("All sprites and icons validated successfully.");
  }
}

main();
