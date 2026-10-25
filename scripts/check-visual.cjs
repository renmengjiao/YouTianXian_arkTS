const fs = require('fs'), path = require('path'), cp = require('child_process'), assert = require('assert/strict');
const root = path.resolve(__dirname, '..'), base = '34cfd7034e8d8745a61dea4af3db930559888225';
const git = args => cp.execFileSync('git', args, { cwd: root, encoding: 'utf8' });
const files = git(['ls-tree', '-r', '--name-only', base]).trim().split('\n');
const resourceFiles = files.filter(f => /\/resources\/|^AppScope\/|\/constants\/|\/defaultability\/|\/module\.json5$|build-profile\.json5$/.test(f));
for (const file of resourceFiles) {
  const actual = fs.readFileSync(path.join(root, file)), expected = cp.execFileSync('git', ['show', base + ':' + file], { cwd: root });
  if (/\.(json5?|ets|svg|xml|txt)$/.test(file)) assert.equal(actual.toString('utf8').replace(/\r\n/g, '\n'), expected.toString('utf8'), 'Changed protected resource/config: ' + file);
  else assert.deepEqual(actual, expected, 'Changed binary resource: ' + file);
}
const styles = /\.(?:fontSize|fontWeight|fontColor|fontFamily|width|height|padding|margin|backgroundColor|border|borderRadius|alignItems|justifyContent|alignSelf|layoutWeight|scrollBar|constraintSize|objectFit|opacity|maxLines|textOverflow|textAlign|color|selectedColor|fill|divider)\s*\(/g;
function styleCalls(text) {
  const result = []; let match;
  while ((match = styles.exec(text))) {
    let i = styles.lastIndex, depth = 1, quote = '', escape = false;
    for (; i < text.length && depth; i++) {
      const c = text[i];
      if (quote) { if (escape) escape = false; else if (c === '\\') escape = true; else if (c === quote) quote = ''; }
      else if ('\'"`'.includes(c)) quote = c;
      else if (c === '(') depth++; else if (c === ')') depth--;
    }
    result.push(text.slice(match.index, i).replace(/\s+/g, ' '));
  }
  return result;
}
const pages = files.filter(f => /\/pages\/.*\.ets$/.test(f) && !/oh_modules/.test(f));
const changes = [];
for (const file of pages) {
  const before = git(['show', base + ':' + file]), after = fs.readFileSync(path.join(root, file), 'utf8');
  assert.deepEqual(styleCalls(after), styleCalls(before), 'Changed style expressions: ' + file);
  const nodes = text => (text.match(/\b(?:Column|Row|Scroll|List|ListItem|Text|TextInput|Button|Image|Blank|Progress|Toggle|Circle|ForEach)\s*\(/g) || []).map(x => x.replace(/\s/g, ''));
  assert.deepEqual(nodes(after), nodes(before), 'Changed component sequence: ' + file);
  if (before !== after.replace(/\r\n/g, '\n')) changes.push(file);
}
const result = { baseline: base, protectedFiles: resourceFiles.length, pages: pages.length, styleAndComponentChecksPassed: true, changedPages: changes };
fs.mkdirSync(path.join(root, 'validation'), { recursive: true }); fs.writeFileSync(path.join(root, 'validation/visual-static.json'), JSON.stringify(result, null, 2));
console.log(JSON.stringify(result, null, 2));
