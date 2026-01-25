import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const files = [
  'contracts/escrow.clar',
  'contracts/roles.clar',
  'contracts/service-marketplace.clar',
  'contracts/ups-solar-App.clar'
];

files.forEach(file => {
  const filePath = path.join(__dirname, file);
  const content = fs.readFileSync(filePath, 'utf8');
  const fixed = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
  fs.writeFileSync(filePath, fixed, 'utf8');
  console.log(`✓ Fixed line endings in ${file}`);
});

console.log('\nAll files fixed! You can now run: npm test');
