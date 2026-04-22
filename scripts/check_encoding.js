/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

const ROOT_DIR = process.cwd();
const FIX_BOM = process.argv.includes('--fix-bom');

const TEXT_EXTENSIONS = new Set([
  '.js',
  '.json',
  '.wxml',
  '.wxss',
  '.ts',
  '.tsx',
  '.java',
  '.xml',
  '.properties',
  '.yml',
  '.yaml',
  '.md',
  '.sql',
  '.html',
  '.css',
  '.vue'
]);

const IGNORE_DIRS = new Set([
  '.git',
  'node_modules',
  'miniprogram_npm',
  'springboot/target',
  'springboot/.mvn',
  'springboot/src/main/resources/static',
  'logs'
]);

const MOJIBAKE_MARKERS = [
  '鐧',
  '璇',
  '缁',
  '鍒',
  '閿',
  '鏃',
  '澶辫触',
  '鍔犺浇',
  '閿欒',
  '璇风◢鍚',
  '浼氳瘽',
  '鎴愬姛'
];

const LATIN_MOJIBAKE_REGEX = /(?:脙|脗|脨|脩|脪|脫|脭|脮|脰|脳|脴|脵|脷|脹|脺|脻){2,}/u;

const issues = {
  bom: [],
  invalidUtf8: [],
  mojibake: []
};

function isIgnoredPath(relativePath) {
  const normalized = relativePath.replace(/\\/g, '/');
  for (const ignore of IGNORE_DIRS) {
    if (normalized === ignore || normalized.startsWith(`${ignore}/`)) {
      return true;
    }
  }
  return false;
}

function walk(dir, relativeBase = '') {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    const relativePath = relativeBase ? `${relativeBase}/${entry.name}` : entry.name;
    if (isIgnoredPath(relativePath)) {
      continue;
    }
    if (entry.isDirectory()) {
      walk(fullPath, relativePath);
      continue;
    }
    if (!entry.isFile()) {
      continue;
    }
    checkFile(fullPath, relativePath);
  }
}

function checkFile(fullPath, relativePath) {
  const normalizedPath = relativePath.replace(/\\/g, '/');
  if (normalizedPath === 'scripts/check_encoding.js' || normalizedPath === 'scripts/check_page_text.js') {
    return;
  }

  const ext = path.extname(relativePath).toLowerCase();
  if (!TEXT_EXTENSIONS.has(ext)) {
    return;
  }

  const buffer = fs.readFileSync(fullPath);
  if (buffer.length === 0) {
    return;
  }

  if (buffer.includes(0)) {
    return;
  }

  const hasBom = buffer.length >= 3
    && buffer[0] === 0xef
    && buffer[1] === 0xbb
    && buffer[2] === 0xbf;

  let contentBuffer = buffer;
  if (hasBom) {
    issues.bom.push(relativePath);
    if (FIX_BOM) {
      contentBuffer = buffer.slice(3);
      fs.writeFileSync(fullPath, contentBuffer);
    }
  }

  const content = contentBuffer.toString('utf8');
  if (content.includes('\uFFFD')) {
    issues.invalidUtf8.push(relativePath);
  }

  const lines = content.split(/\r?\n/);
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    if (!line || line.trim().length === 0) {
      continue;
    }
    if (isLikelyMojibake(line)) {
      issues.mojibake.push({
        file: relativePath,
        line: i + 1,
        snippet: line.trim().slice(0, 120)
      });
      if (issues.mojibake.length >= 500) {
        break;
      }
    }
  }
}

function isLikelyMojibake(line) {
  if (!line) {
    return false;
  }
  if (LATIN_MOJIBAKE_REGEX.test(line)) {
    return true;
  }
  for (const marker of MOJIBAKE_MARKERS) {
    if (line.includes(marker)) {
      return true;
    }
  }
  return false;
}

function printSummary() {
  console.log(`\n[encoding-check] root=${ROOT_DIR}`);
  console.log(`[encoding-check] BOM files: ${issues.bom.length}`);
  console.log(`[encoding-check] invalid UTF-8 files: ${issues.invalidUtf8.length}`);
  console.log(`[encoding-check] mojibake lines: ${issues.mojibake.length}`);

  if (issues.bom.length > 0) {
    const bomPreview = issues.bom.slice(0, 30);
    console.log('\n[BOM]');
    bomPreview.forEach((item) => console.log(`- ${item}`));
    if (issues.bom.length > bomPreview.length) {
      console.log(`... and ${issues.bom.length - bomPreview.length} more`);
    }
    if (FIX_BOM) {
      console.log('[BOM] BOM already removed from files above.');
    }
  }

  if (issues.invalidUtf8.length > 0) {
    console.log('\n[invalid-utf8]');
    issues.invalidUtf8.slice(0, 30).forEach((item) => console.log(`- ${item}`));
  }

  if (issues.mojibake.length > 0) {
    console.log('\n[mojibake-preview]');
    issues.mojibake.slice(0, 60).forEach((item) => {
      console.log(`- ${item.file}:${item.line} ${item.snippet}`);
    });
    if (issues.mojibake.length > 60) {
      console.log(`... and ${issues.mojibake.length - 60} more`);
    }
  }
}

walk(ROOT_DIR);
printSummary();

const blockingIssueCount = issues.invalidUtf8.length + issues.mojibake.length + (FIX_BOM ? 0 : issues.bom.length);
if (blockingIssueCount > 0) {
  console.error('\n[encoding-check] found blocking encoding issues.');
  process.exit(1);
}

console.log('\n[encoding-check] passed.');
process.exit(0);
