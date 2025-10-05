import { readFile, writeFile, mkdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { glob } from 'glob';
import { inlineSource } from 'inline-source';
import { minify as minifyHtml } from 'html-minifier-terser';

const INPUT_DIR = path.resolve(process.cwd(), 'source');
const OUTPUT_DIR = path.resolve(process.cwd(), 'gen');

async function ensureDir(dir) {
    try {
        await stat(dir);
    } catch {
        await mkdir(dir, { recursive: true });
    }
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

async function main() {
    const files = await glob('*.html', {
        cwd: INPUT_DIR,
        nodir: true,
        absolute: true,
        windowsPathsNoEscape: true
    });

    if (files.length === 0) {
        console.error(`No HTML files found in: ${INPUT_DIR}`);
        process.exit(1);
    }

    const written = await Promise.all(files.map(processOne));
    console.log('Wrote:');
    written.forEach(p => console.log(' -', path.relative(process.cwd(), p)));
}

main().catch(err => {
    console.error(err);
    process.exit(1);
});
