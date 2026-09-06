const copyButton = document.getElementById('copy-button');
let copyState = { text: '', label: '', revision: -1, copiedLabel: '', successText: '', failureText: '' };
let pendingCopy = null;

function setCopyButton(encodedData) {
    const bytes = Uint8Array.from(atob(encodedData), c => c.charCodeAt(0));
    const data = JSON.parse(new TextDecoder('utf-8').decode(bytes));
    const [text, label, revision, messages] = data;
    if (typeof text !== 'string' || typeof label !== 'string' || !Number.isInteger(revision)) return;
    if (!Array.isArray(messages) || messages.length !== 4 || !messages.every(message => typeof message === 'string')) return;
    if (revision <= copyState.revision) return;

    const [copiedLabel, tooltip, successText, failureText] = messages;
    copyState = { text, label, revision, copiedLabel, successText, failureText };
    copyButton.textContent = label;
    copyButton.title = tooltip;
    copyButton.disabled = text.length === 0;
}

document.addEventListener('copy', (event) => {
    if (!pendingCopy || !event.clipboardData) return;
    event.clipboardData.setData('text/plain', pendingCopy.text);
    event.preventDefault();
    pendingCopy.handled = true;
});

copyButton.addEventListener('click', () => {
    if (copyButton.disabled || !copyState.text) return;

    const request = { text: copyState.text, revision: copyState.revision, handled: false };
    pendingCopy = request;
    let copied = false;
    try {
        copied = document.execCommand('copy') === true && request.handled;
    } catch {
        copied = false;
    }
    pendingCopy = null;

    if (request.revision === copyState.revision) {
        copyButton.textContent = copied ? copyState.copiedLabel : copyState.label;
        copyButton.title = copied ? copyState.successText : copyState.failureText;
    }
    if (typeof A3API !== 'undefined') {
        A3API.SendAlert(JSON.stringify([copied ? 'copied' : 'failed', request.revision]));
    }
});
