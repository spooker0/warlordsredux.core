document.addEventListener('wheel', function (e) {
    const el = document.elementFromPoint(e.clientX, e.clientY);
    if (el && el.closest('.panel')) {
        el.closest('.panel').scrollTop += e.deltaY;
        e.preventDefault();
    }
}, { passive: false });

const wrapper = document.querySelector('.menu-wrapper');
const header = document.querySelector('.menu-title');

const closeButton = document.createElement('div');
closeButton.className = 'close-button';
closeButton.innerHTML = '&times;';
wrapper.appendChild(closeButton);
closeButton.addEventListener('mousedown', function () {
    A3API.SendAlert('exit');
});

const pos = { x1: 0, y1: 0, x2: 0, y2: 0 };

const onMouseMove = (e) => {
    e.preventDefault();
    const { clientX, clientY } = e;
    pos.x1 = pos.x2 - clientX;
    pos.y1 = pos.y2 - clientY;
    pos.x2 = clientX;
    pos.y2 = clientY;
    wrapper.style.top = `${wrapper.offsetTop - pos.y1}px`;
    wrapper.style.left = `${wrapper.offsetLeft - pos.x1}px`;
};

const onMouseUp = () => {
    document.removeEventListener('mouseup', onMouseUp);
    document.removeEventListener('mousemove', onMouseMove);
};

const onMouseDown = (e) => {
    e.preventDefault();
    pos.x2 = e.clientX;
    pos.y2 = e.clientY;
    document.addEventListener('mouseup', onMouseUp);
    document.addEventListener('mousemove', onMouseMove);
};

header.addEventListener('mousedown', onMouseDown);

const fpsDisplay = document.createElement('div');
fpsDisplay.className = 'fps-display';
document.body.appendChild(fpsDisplay);

let frameTime = 0, frameCount = 0;
let lastLoop = performance.now();
const fpsLoop = () => {
    const thisLoop = performance.now();
    frameTime += (thisLoop - lastLoop - frameTime) / 20;
    lastLoop = thisLoop;
    frameCount++;
    requestAnimationFrame(fpsLoop);
};
setInterval(() => {
    if (frameCount > 60) {
        fpsDisplay.textContent = `MENU FPS: ${(1000 / frameTime).toFixed(2)}`;
    } else {
        fpsDisplay.textContent = `MENU FPS: -`;
    }
}, 100);
fpsLoop();