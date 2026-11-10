const { execSync } = require('child_process');
const fs = require('fs');
try {
  const out = execSync('C:/flutter/bin/flutter.bat test test/overflow_test.dart --plain-name="/dashboard/student"');
  console.log('Passed!');
} catch (e) {
  fs.writeFileSync('err.txt', (e.stdout ? e.stdout.toString() : '') + '\n' + (e.stderr ? e.stderr.toString() : ''));
  console.log('Saved to err.txt');
}
