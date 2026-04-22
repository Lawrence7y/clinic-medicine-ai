/* eslint-disable no-console */
const fs = require('fs');
const path = require('path');

const ROOT_DIR = process.cwd();
const PAGE_EXTENSIONS = new Set(['.wxml', '.html']);
const UI_ROOT_PREFIXES = [
  'pages/',
  'components/',
  'springboot/src/main/resources/templates/clinic/'
];
const IGNORE_DIRS = new Set([
  '.git',
  'node_modules',
  'miniprogram_npm',
  'springboot/target',
  'springboot/.mvn',
  'springboot/src/main/resources/static',
  'logs'
]);
const DISPLAY_ATTRS = ['title', 'placeholder', 'label', 'buttonText', 'alt', 'description', 'confirmText', 'cancelText'];
const ALLOWED_TERMS = /\b(AI|API|JSON|OCR|URL|ID|HTTP|HTTPS|SQL|WXML|WXSS|JS|TS|MS|PDF|JPG|PNG|MB|AB)\b/gi;
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

const issues = {
  englishText: [],
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
  const ext = path.extname(relativePath).toLowerCase();
  if (!PAGE_EXTENSIONS.has(ext)) {
    return;
  }
  if (!UI_ROOT_PREFIXES.some((prefix) => normalizedPath.startsWith(prefix))) {
    return;
  }

  const content = fs.readFileSync(fullPath, 'utf8');
  const candidateTexts = collectCandidates(content);
  candidateTexts.forEach((item) => {
    if (isLikelyMojibake(item.text)) {
      issues.mojibake.push({
        file: relativePath,
        line: getLineNumber(content, item.index),
        text: item.text
      });
      return;
    }
    const englishWords = extractEnglishWords(item.text);
    if (englishWords.length > 0) {
      issues.englishText.push({
        file: relativePath,
        line: getLineNumber(content, item.index),
        text: item.text,
        words: englishWords.join(', ')
      });
    }
  });
}

function collectCandidates(content) {
  const sanitized = content
    .replace(/<script[\s\S]*?<\/script>/gi, '')
    .replace(/<style[\s\S]*?<\/style>/gi, '');
  const candidates = [];
  const textRegex = />([^<]+)</g;
  const attrRegex = new RegExp(`(?:${DISPLAY_ATTRS.join('|')})\\s*=\\s*(['"])([\\s\\S]*?)\\1`, 'gi');
  const headerRegex = /header\((['"])(.*?)\1\)/g;

  collectFromRegex(candidates, sanitized, textRegex, 1);
  collectFromRegex(candidates, sanitized, attrRegex, 2);
  collectFromRegex(candidates, sanitized, headerRegex, 2);

  return candidates;
}

function collectFromRegex(output, source, regex, groupIndex) {
  let match = regex.exec(source);
  while (match) {
    const text = normalizeText(match[groupIndex]);
    if (text) {
      output.push({ text, index: match.index });
    }
    match = regex.exec(source);
  }
}

function normalizeText(raw) {
  return String(raw || '')
    .replace(/\{\{[\s\S]*?\}\}/g, ' ')
    .replace(/\[\[[\s\S]*?\]\]/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&times;/gi, '×')
    .replace(/&raquo;/gi, '»')
    .replace(/\s+/g, ' ')
    .trim();
}

function isLikelyMojibake(text) {
  return MOJIBAKE_MARKERS.some((marker) => text.includes(marker));
}

function extractEnglishWords(text) {
  if (!text || /(?:bind|data-|class|variant|size|status|wx:|t-class|th:|\$\{|session\.|ctx \+|=|\/>|\{\{|\}\}|&&)/i.test(text)) {
    return [];
  }
  if (/^[yMdHms:\- ]+$/i.test(text)) {
    return [];
  }

  const normalized = text
    .replace(ALLOWED_TERMS, ' ')
    .replace(/https?:\/\/\S+/gi, ' ')
    .replace(/[0-9]+/g, ' ')
    .replace(/[_./:()[\]{}|+*#@&=,，。！？；：“”"'、\-]/g, ' ')
    .trim();

  if (!normalized) {
    return [];
  }
  if (/^(例如|示例|比如)[:：]\s*[A-Za-z0-9_.:/ -]+$/u.test(text)) {
    return [];
  }

  const words = normalized.match(/[A-Za-z]{2,}/g) || [];
  return Array.from(new Set(words));
}

function getLineNumber(content, index) {
  return content.slice(0, index).split(/\r?\n/).length;
}

function printIssues() {
  console.log(`\n[page-text-check] root=${ROOT_DIR}`);
  console.log(`[page-text-check] english ui texts: ${issues.englishText.length}`);
  console.log(`[page-text-check] mojibake texts: ${issues.mojibake.length}`);

  if (issues.englishText.length > 0) {
    console.log('\n[english-ui-preview]');
    issues.englishText.slice(0, 80).forEach((item) => {
      console.log(`- ${item.file}:${item.line} ${item.text} [${item.words}]`);
    });
    if (issues.englishText.length > 80) {
      console.log(`... and ${issues.englishText.length - 80} more`);
    }
  }

  if (issues.mojibake.length > 0) {
    console.log('\n[mojibake-preview]');
    issues.mojibake.slice(0, 80).forEach((item) => {
      console.log(`- ${item.file}:${item.line} ${item.text}`);
    });
    if (issues.mojibake.length > 80) {
      console.log(`... and ${issues.mojibake.length - 80} more`);
    }
  }
}

walk(ROOT_DIR);
printIssues();

if (issues.englishText.length > 0 || issues.mojibake.length > 0) {
  console.error('\n[page-text-check] found non-Chinese or mojibake page text.');
  process.exit(1);
}

console.log('\n[page-text-check] passed.');
