import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(process.argv[2] ?? 'dist');
const maxFileSize = 25 * 1024 * 1024;
const forbiddenExtensions = new Set(['.adoc', '.sh', '.md', '.rb']);
const forbiddenNames = new Set(['.env', '.git', 'CNAME', 'Gemfile', 'Gemfile.lock', 'package.json', 'package-lock.json']);
const failures = [];
const checkedTargets = new Set();

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const absolute = path.join(directory, entry.name);
    if (entry.isSymbolicLink()) {
      failures.push(`${path.relative(root, absolute)}: symbolic links must not be published`);
      return [];
    }
    return entry.isDirectory() ? walk(absolute) : [absolute];
  });
}

if (!fs.existsSync(root) || !fs.statSync(root).isDirectory()) {
  console.error(`Publish directory does not exist: ${root}`);
  process.exit(1);
}

if (!fs.existsSync(path.join(root, 'index.html'))) {
  failures.push('missing handcrafted dist/index.html');
}

const files = walk(root);
for (const file of files) {
  const relative = path.relative(root, file);
  const stats = fs.statSync(file);
  if (stats.size > maxFileSize) failures.push(`${relative}: ${stats.size} bytes exceeds 25 MiB`);
  if (forbiddenExtensions.has(path.extname(file)) || relative.split(path.sep).some((part) => forbiddenNames.has(part))) {
    failures.push(`${relative}: development/source file must not be published`);
  }
}

function validateUrl(sourceFile, url) {
  if (/^(?:[a-z]+:|#|\/\/)/i.test(url)) return;

  let clean;
  let browserPath;
  try {
    clean = decodeURIComponent(url.split(/[?#]/, 1)[0].replaceAll('&amp;', '&'));
    if (!clean) return;
    const sourcePath = `/${path.relative(root, sourceFile).split(path.sep).join('/')}`;
    browserPath = decodeURIComponent(new URL(clean, `https://site.invalid${sourcePath}`).pathname);
  } catch {
    failures.push(`${path.relative(root, sourceFile)}: invalid local URL: ${url}`);
    return;
  }

  const target = path.join(root, browserPath);
  const checkKey = `${sourceFile}\0${target}`;
  if (checkedTargets.has(checkKey)) return;
  checkedTargets.add(checkKey);

  if (!target.startsWith(`${root}${path.sep}`) && target !== root) {
    failures.push(`${path.relative(root, sourceFile)}: link escapes publish directory: ${url}`);
  } else if (!fs.existsSync(target)) {
    failures.push(`${path.relative(root, sourceFile)}: missing local target: ${url}`);
  } else if (fs.statSync(target).isDirectory() && !fs.existsSync(path.join(target, 'index.html'))) {
    failures.push(`${path.relative(root, sourceFile)}: directory link has no index.html: ${url}`);
  }
}

const htmlUrlPattern = /\b(?:href|poster|src)\s*=\s*["']([^"']+)["']/gi;
const cssUrlPattern = /\burl\(\s*["']?([^"')]+)["']?\s*\)/gi;

for (const htmlFile of files.filter((file) => path.extname(file) === '.html')) {
  const html = fs.readFileSync(htmlFile, 'utf8');
  for (const match of html.matchAll(htmlUrlPattern)) validateUrl(htmlFile, match[1]);
  for (const match of html.matchAll(cssUrlPattern)) validateUrl(htmlFile, match[1]);
}

for (const cssFile of files.filter((file) => path.extname(file) === '.css')) {
  const css = fs.readFileSync(cssFile, 'utf8');
  for (const match of css.matchAll(cssUrlPattern)) {
    validateUrl(cssFile, match[1]);
  }
}

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}

console.log(`Validated ${files.length} deployable files in ${path.relative(process.cwd(), root) || '.'}.`);
