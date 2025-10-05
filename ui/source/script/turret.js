const ns = "http://www.w3.org/2000/svg";

function setLines(points) {
    const container = document.querySelector('#box-lines');
    if (!container) return;

    container.textContent = '';

    let segments;
    if (Array.isArray(points[0]) && Array.isArray(points[0][0])) {
        segments = points;
    } else {
        segments = [];
        for (let i = 0; i + 1 < points.length; i += 2) {
            segments.push([points[i], points[i + 1]]);
        }
    }

    const isValidPoint = (p) =>
        p[0] != -1 && p[0] != -1 &&
        p[1] != -1 && p[1] != -1;

    const svgNS = 'http://www.w3.org/2000/svg';

    for (const [a, b] of segments) {
        if (!isValidPoint(a) || !isValidPoint(b)) continue;

        const line = document.createElementNS(svgNS, 'line');
        line.setAttribute('x1', a[0]);
        line.setAttribute('y1', a[1]);
        line.setAttribute('x2', b[0]);
        line.setAttribute('y2', b[1]);
        container.appendChild(line);
    }
}

function setBoxLines(points) {
    const segments = [];
    for (let i = 0; i < points.length; i++) {
        segments.push([points[i], points[(i + 1) % points.length]]);
    }
    setLines(segments);
}

function setCrosshair(x, y, crossEl, name, textEl, angleDeg = 0) {
    const halfSizePx = 15;
    const dx = halfSizePx / window.innerWidth;
    const dy = halfSizePx / window.innerHeight;

    const hLine = crossEl.querySelector(".ref-h");
    hLine.setAttribute("x1", x - dx);
    hLine.setAttribute("y1", y);
    hLine.setAttribute("x2", x + dx);
    hLine.setAttribute("y2", y);

    const vLine = crossEl.querySelector(".ref-v");
    vLine.setAttribute("x1", x);
    vLine.setAttribute("y1", y - dy);
    vLine.setAttribute("x2", x);
    vLine.setAttribute("y2", y + dy);

    if (name) {
        textEl.textContent = name.toUpperCase();
        textEl.style.display = "block";
        textEl.style.position = "fixed";
        textEl.style.left = `${(x * window.innerWidth) + 10}px`;
        textEl.style.top = `${(y * window.innerHeight)}px`;
    } else {
        textEl.style.display = "none";
    }
}

function setAzimuthBar(offsetX, x, y, crossEl, name, textEl, angleDeg, isTurnGood, isElevGood) {
    const a = angleDeg * Math.PI / 180;

    const aspect = window.innerHeight / window.innerWidth;
    let slope = Math.tan(a) * aspect;

    // avoid infinities
    const MAX_SLOPE = 1e6;
    if (!Number.isFinite(slope)) slope = Math.sign(slope || 1) * MAX_SLOPE;
    slope = Math.max(Math.min(slope, MAX_SLOPE), -MAX_SLOPE);

    const y1 = y - 0.1, y2 = y + 0.1;
    const x1 = x + (y1 - 0.5) * slope;
    const x2 = x + (y2 - 0.5) * slope;
    const centerX = x + (y - 0.5) * slope;

    const hLine = crossEl.querySelector(".ref-h");
    hLine.setAttribute("x1", offsetX);
    hLine.setAttribute("y1", y);
    hLine.setAttribute("x2", centerX);
    hLine.setAttribute("y2", y);

    if (isTurnGood) {
        hLine.setAttribute("stroke", "lime");
    } else {
        hLine.setAttribute("stroke", "red");
    }

    const vLine = crossEl.querySelector(".ref-v");
    vLine.setAttribute("x1", x1);
    vLine.setAttribute("y1", y1);
    vLine.setAttribute("x2", x2);
    vLine.setAttribute("y2", y2);

    const vLine2 = crossEl.querySelector(".ref-v2");
    vLine2.setAttribute("x1", centerX);
    vLine2.setAttribute("y1", y1);
    vLine2.setAttribute("x2", centerX);
    vLine2.setAttribute("y2", y2);

    if (isElevGood) {
        vLine.setAttribute("stroke", "lime");
        vLine2.setAttribute("stroke", "lime");
    } else {
        vLine.setAttribute("stroke", "red");
        vLine2.setAttribute("stroke", "red");
    }

    if (name) {
        textEl.textContent = name.toUpperCase();
        textEl.style.display = "block";
        textEl.style.position = "fixed";
        textEl.style.left = `${(x * window.innerWidth) + 10}px`;
        textEl.style.top = `${y * window.innerHeight}px`;
    } else {
        textEl.style.display = "none";
    }
}

function setReferencePoint(x, y) {
    const crossEl = document.getElementById("ref-point");
    const textEl = document.querySelector(".ref-label-point");
    setCrosshair(x, y, crossEl, "REF", textEl);
}

function setDesiredPoint(x1, x2, y2, angle, isTurnGood, isElevGood) {
    const textEl = document.querySelector(".ref-label-nose");
    const noseEl = document.getElementById("ref-point-nose");
    if (x1 === -1) {
        noseEl.style.display = "none";
        textEl.style.display = "none";
        return;
    }
    noseEl.style.display = "block";
    setAzimuthBar(x1, x2, y2, noseEl, "PYLON TURN", textEl, angle, isTurnGood, isElevGood);
}

function setCrosshairs(points) {
    const crosses = [
        document.getElementById("ref-cross-1"),
        document.getElementById("ref-cross-2"),
        document.getElementById("ref-cross-3"),
    ];
    for (let i = 0; i < crosses.length; i++) {
        const crossEl = crosses[i];
        const textEl = document.querySelector(`.ref-label-${i + 1}`);
        if (i < points.length) {
            crossEl.style.display = "block";
            const [x, y, name] = points[i];
            setCrosshair(x, y, crossEl, name, textEl);
        } else {
            crossEl.style.display = "none";
            textEl.style.display = "none";
        }
    }
}