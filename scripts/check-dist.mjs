import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(process.argv[2] ?? 'dist');
const maxFileSize = 25 * 1024 * 1024;
const forbiddenExtensions = new Set(['.adoc', '.sh', '.md', '.rb']);
const forbiddenNames = new Set(['.env', '.git', 'CNAME', 'Gemfile', 'Gemfile.lock', 'package.json', 'package-lock.json']);
const failures = [];

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

const urlPattern = /\b(?:href|poster|src)\s*=\s*["']([^"']+)["']/gi;
for (const htmlFile of files.filter((file) => path.extname(file) === '.html')) {
  const html = fs.readFileSync(htmlFile, 'utf8');
  for (const match of html.matchAll(urlPattern)) {
    const url = match[1];
    if (/^(?:[a-z]+:|#|\/\/)/i.test(url)) continue;
    const clean = decodeURIComponent(url.split(/[?#]/, 1)[0].replaceAll('&amp;', '&'));
    if (!clean) continue;
    const pagePath = `/${path.relative(root, htmlFile).split(path.sep).join('/')}`;
    const browserPath = decodeURIComponent(new URL(clean, `https://site.invalid${pagePath}`).pathname);
    const target = path.join(root, browserPath);
    if (!target.startsWith(`${root}${path.sep}`) && target !== root) {
      failures.push(`${path.relative(root, htmlFile)}: link escapes publish directory: ${url}`);
    } else if (!fs.existsSync(target)) {
      failures.push(`${path.relative(root, htmlFile)}: missing local target: ${url}`);
    } else if (fs.statSync(target).isDirectory() && !fs.existsSync(path.join(target, 'index.html'))) {
      failures.push(`${path.relative(root, htmlFile)}: directory link has no index.html: ${url}`);
    }
  }
}

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}

console.log(`Validated ${files.length} deployable files in ${path.relative(process.cwd(), root) || '.'}.`);
