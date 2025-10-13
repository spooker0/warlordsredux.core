import { readFile, writeFile, mkdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { glob } from 'glob';
import { inlineSource } from 'inline-source';
import { minify as minifyHtml } from 'html-minifier-terser';
import { fileURLToPath } from 'node:url';

export const INPUT_DIR = path.resolve(process.cwd(), 'source');
export const OUTPUT_DIR = path.resolve(process.cwd(), 'gen');

async function ensureDir(dir) {
    try { await stat(dir); } catch { await mkdir(dir, { recursive: true }); }
}

async function processOne(htmlPath) {
    const html = await readFile(htmlPath, 'utf8');
    const inlined = await inlineSource(html, {
        rootpath: path.dirname(htmlPath),
        compress: true,
        svgAsImage: true,
        swallowErrors: false
    });
    const minimized = await minifyHtml(inlined, {
        collapseWhitespace: true,
        removeComments: true,
        removeRedundantAttributes: true,
        removeEmptyAttributes: true,
        minifyCSS: true,
        minifyJS: true,
        keepClosingSlash: true,
        sortAttributes: true,
        sortClassName: true
    });
    await ensureDir(OUTPUT_DIR);
    const outPath = path.join(OUTPUT_DIR, path.basename(htmlPath));
    await writeFile(outPath, minimized, 'utf8');
    return outPath;
}

export async function runBuild() {
    const files = await glob('*.html', {
        cwd: INPUT_DIR,
        nodir: true,
        absolute: true,
        windowsPathsNoEscape: true
    });
    if (files.length === 0) {
        console.error(`No HTML files found in: ${INPUT_DIR}`);
        return { written: [], count: 0 };
    }
    const written = await Promise.all(files.map(processOne));
    console.log('Wrote:');
    written.forEach(p => console.log(' -', path.relative(process.cwd(), p)));
    return { written, count: written.length };
}

const isDirect = fileURLToPath(import.meta.url) === path.resolve(process.argv[1] || '');
if (isDirect) {
    runBuild().catch(err => {
        console.error(err);
        process.exit(1);
    });
}