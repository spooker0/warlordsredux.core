import { watch } from 'node:fs';
import path from 'node:path';
import { runBuild, INPUT_DIR } from './build.mjs';

const DEBOUNCE_MS = 150;
let pending = null;

function scheduleBuild(reason) {
    if (pending) clearTimeout(pending);
    pending = setTimeout(async () => {
        pending = null;
        const start = Date.now();
        console.log(`[watch] Change detected (${reason}). Rebuilding...`);
        try {
            const { count } = await runBuild();
            const ms = Date.now() - start;
            console.log(`[watch] Done. Processed ${count} HTML file(s) in ${ms}ms.\n`);
        } catch (e) {
            console.error('[watch] Build failed:\n', e, '\n');
        }
    }, DEBOUNCE_MS);
}

await runBuild().catch(err => {
    console.error(err);
    process.exit(1);
});

const extsThatMatter = new Set(['.html', '.css', '.js', '.mjs', '.cjs', '.svg']);
watch(INPUT_DIR, { recursive: true }, (eventType, filename) => {
    if (!filename) { scheduleBuild('unknown'); return; }
    const ext = path.extname(filename).toLowerCase();
    if (extsThatMatter.has(ext)) scheduleBuild(`${eventType}: ${filename}`);
});

process.on('SIGINT', () => {
    console.log('\n[watch] Stopped.');
    process.exit(0);
});

console.log(`[watch] Watching ${INPUT_DIR} (recursive) …\n`);