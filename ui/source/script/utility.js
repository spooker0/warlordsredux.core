function atobr(str) {
    const bytes = Uint8Array.from(atob(str), c => c.charCodeAt(0));
    const text = new TextDecoder('utf-8').decode(bytes);
    return text;
}

function btoar(str) {
    const bytes = new TextEncoder().encode(str);
    const binary = Array.from(bytes, b => String.fromCharCode(b)).join('');
    return btoa(binary);
}