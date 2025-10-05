import { createRequire } from 'node:module';
import { execSync } from 'node:child_process';
import { pathToFileURL } from 'node:url';

const require = createRequire(import.meta.url);
let globalRoot;
function getGlobalRoot() {
    if (!globalRoot) {
        try { globalRoot = process.env.NODE_PATH?.split(';')[0]; } catch { }
        if (!globalRoot) globalRoot = execSync('npm root -g').toString().trim();
    }
    return globalRoot;
}

export async function resolve(specifier, context, nextResolve) {
    try {
        return await nextResolve(specifier, context);
    } catch {
        const root = getGlobalRoot();
        try {
            const resolved = require.resolve(specifier, { paths: [root] });
            return { url: pathToFileURL(resolved).href, shortCircuit: true };
        } catch {
            return await nextResolve(specifier, context);
        }
    }
}
