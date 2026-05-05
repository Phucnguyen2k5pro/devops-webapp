const { execFileSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const ignoredDirectories = new Set(['.git', 'node_modules', 'phase1', 'phase2', 'phase3']);

function collectJavaScriptFiles(directory, result = []) {
  const entries = fs.readdirSync(directory, { withFileTypes: true });

  for (const entry of entries) {
    const fullPath = path.join(directory, entry.name);

    if (entry.isDirectory()) {
      if (!ignoredDirectories.has(entry.name)) {
        collectJavaScriptFiles(fullPath, result);
      }
      continue;
    }

    if (entry.isFile() && entry.name.endsWith('.js')) {
      result.push(fullPath);
    }
  }

  return result;
}

const files = collectJavaScriptFiles(rootDir);

for (const file of files) {
  execFileSync(process.execPath, ['--check', file], { stdio: 'inherit' });
}

console.log(`Build check passed. Checked ${files.length} JavaScript files.`);
