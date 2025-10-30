document.imageCache = {};

let KILLFEED_TIMEOUT_MS = 10000;
let MIN_GAP_MS = 500;
let RIBBON_MIN_SHOW_MS = 5000;
let SHOW_HIT_INDICATOR = true;
let MINIMALISTIC = false;

const killfeedQueue = [];
let isProcessingQueue = false;
let lastAddTimestamp = 0;
let totalPoints = 0;
let displayedPoints = 0;

function formatPoints(n) {
    return new Number(n).toLocaleString();
}

const activeRafHandles = new WeakMap();

function animatePoints(el, from, to) {
    const startValue = Number(from) || 0;
    const endValue = Number(to) || 0;

    if (MINIMALISTIC) {
        displayedPoints = endValue;
        el.textContent = endValue > 0 ? formatPoints(endValue) : "";
        return;
    }

    const previousHandle = activeRafHandles.get(el);
    if (previousHandle !== undefined) cancelAnimationFrame(previousHandle);

    if (startValue === endValue) {
        displayedPoints = endValue;
        el.textContent = endValue > 0 ? formatPoints(endValue) : "";
        activeRafHandles.delete(el);
        return;
    }

    const durationMs = 500;

    const startTime = performance.now();
    const easeOutQuint = t => 1 - Math.pow(1 - t, 5);

    function animatePointStep(now) {
        const elapsed = now - startTime;
        const t = Math.min(1, elapsed / durationMs);
        const eased = easeOutQuint(t);
        const currentValue = Math.round(startValue + (endValue - startValue) * eased);

        if (currentValue !== displayedPoints) {
            displayedPoints = currentValue;
            el.textContent = currentValue > 0 ? formatPoints(currentValue) : "";
        }

        if (t < 1) {
            const handle = requestAnimationFrame(animatePointStep);
            activeRafHandles.set(el, handle);
        } else {
            activeRafHandles.delete(el);
        }
    }

    const handle = requestAnimationFrame(animatePointStep);
    activeRafHandles.set(el, handle);
}

function addKillfeed(killfeedItems, times = 1) {
    const [displayText, points, customColor, iconUrl] = JSON.parse(killfeedItems) || [];
    if (SHOW_HIT_INDICATOR && customColor === "#de0808") hitIndicator();
    for (let i = 0; i < times; i++) {
        killfeedQueue.push([displayText, points, customColor, iconUrl]);
    }
    processQueue();
}

function processQueue() {
    if (isProcessingQueue) return;
    isProcessingQueue = true;

    const step = () => {
        if (killfeedQueue.length === 0) { isProcessingQueue = false; return; }

        const now = Date.now();
        const waitTime = Math.max(0, MIN_GAP_MS - (now - lastAddTimestamp));

        setTimeout(() => {
            const [displayText, points, customColor, iconUrl] = killfeedQueue.shift();
            addKillfeedImmediate(displayText, points, customColor, iconUrl);
            lastAddTimestamp = Date.now();
            step();
        }, waitTime);
    };

    step();
}

const activeAnimations = new WeakMap();
function flipReorder(containerElement, elementToMove) {
    const ANIMATION_DURATION_MS = 200;
    const ANIMATION_EASING = 'cubic-bezier(0.2, 0.9, 0.2, 1.0)';

    const initialRects = new Map();
    const childrenBefore = Array.from(containerElement.children);

    for (const element of childrenBefore) {
        initialRects.set(element, element.getBoundingClientRect());

        const prev = activeAnimations.get(element);
        if (prev) {
            try { prev.cancel(); } catch { }
            activeAnimations.delete(element);
        }
    }

    containerElement.appendChild(elementToMove);

    const childrenAfter = Array.from(containerElement.children);
    const finishedPromises = [];

    containerElement.classList.add('unclipped');

    for (const element of childrenAfter) {
        const fromRect = initialRects.get(element);
        if (!fromRect) continue;

        const toRect = element.getBoundingClientRect();
        const deltaX = fromRect.left - toRect.left;
        const deltaY = fromRect.top - toRect.top;

        if (deltaX === 0 && deltaY === 0) continue;

        if (MINIMALISTIC) {
            containerElement.classList.remove('unclipped');
            continue;
        }

        const animation = element.animate(
            [{ transform: `translate(${deltaX}px, ${deltaY}px)` }, { transform: 'translate(0, 0)' }],
            { duration: ANIMATION_DURATION_MS, easing: ANIMATION_EASING, fill: 'both' }
        );

        activeAnimations.set(element, animation);

        const settled = animation.finished
            .catch(() => { })
            .then(() => {
                try { animation.cancel(); } catch { }
                element.style.transform = '';
                activeAnimations.delete(element);
            });

        finishedPromises.push(settled);
    }

    Promise.allSettled(finishedPromises).then(() => {
        containerElement.classList.remove('unclipped');
    });
}

function injectImage(img, iconUrl) {
    if (document.imageCache[iconUrl]) {
        img.src = document.imageCache[iconUrl];
        return;
    }
    A3API.RequestTexture(iconUrl, 32).then(imageContent => {
        img.src = imageContent;
        document.imageCache[iconUrl] = imageContent;
    });
}

function addIconIndependent(iconUrl) {
    if (!iconUrl) return;
    const iconsRow = document.getElementById("kf-icons-row");

    const iconEl = document.createElement("img");
    iconEl.className = "kf-icon enter";
    injectImage(iconEl, iconUrl);
    iconsRow.appendChild(iconEl);

    iconEl._timeout = setTimeout(() => {
        iconEl.classList.remove("enter");
        iconEl.classList.add("exit");
        iconEl.addEventListener("animationend", () => iconEl.remove(), { once: true });
    }, KILLFEED_TIMEOUT_MS);
}

function addKillfeedImmediate(displayText, points, customColor, iconUrl) {
    A3API.SendAlert("A");

    const badgesRow = document.getElementById("kf-badges-row");
    const pointsBox = document.getElementById("kf-points");
    const pulse = (el, cls) => { if (!el) return; el.classList.remove(cls); void el.offsetWidth; el.classList.add(cls); };

    addIconIndependent(iconUrl);

    let badge = Array.from(badgesRow.querySelectorAll(".kf-badge"))
        .find(b => b.dataset.label === displayText && b.dataset.customColor === (customColor || ""));

    const incomingPoints = points | 0;

    if (badge) {
        const labelEl = badge.querySelector(".kf-label");
        let multEl = badge.querySelector(".kf-mult");

        const newCount = (parseInt(badge.dataset.count || "1", 10) + 1);
        badge.dataset.count = String(newCount);

        const newPoints = (parseInt(badge.dataset.points || "0", 10) + incomingPoints);
        badge.dataset.points = String(newPoints);

        if (labelEl) labelEl.textContent = displayText;

        if (newCount > 1) {
            if (!multEl) {
                multEl = document.createElement("span");
                multEl.className = "kf-mult";
                badge.appendChild(multEl);
            }
            multEl.innerHTML = `&times; ${newCount}`;
        } else if (multEl) {
            multEl.remove();
        }

        flipReorder(badgesRow, badge);

        const target = totalPoints + incomingPoints;
        animatePoints(pointsBox, displayedPoints, target);
        totalPoints = target;

        pulse(badge, "merge");
        pulse(pointsBox, "points-merge");

        clearTimeout(badge._timeout);
        badge._timeout = setTimeout(() => removeBadge(badge), KILLFEED_TIMEOUT_MS);
        return;
    }

    const newBadge = document.createElement("span");
    newBadge.className = "kf-badge enter";
    newBadge.dataset.label = displayText;
    newBadge.dataset.count = "1";
    newBadge.dataset.points = String(incomingPoints);
    newBadge.dataset.customColor = customColor || "";

    const labelSpan = document.createElement("span");
    labelSpan.className = "kf-label";
    labelSpan.textContent = displayText;
    newBadge.appendChild(labelSpan);

    if (customColor) {
        newBadge.style.borderColor = customColor;
        newBadge.style.color = customColor;
    }

    badgesRow.appendChild(newBadge);

    const target = totalPoints + incomingPoints;
    animatePoints(pointsBox, displayedPoints, target);
    totalPoints = target;
    pulse(pointsBox, "points-merge");

    newBadge._timeout = setTimeout(() => removeBadge(newBadge), KILLFEED_TIMEOUT_MS);
}

function renderTotalPoints(pointsBox) {
    animatePoints(pointsBox, displayedPoints, totalPoints);
}

function removeBadge(badge) {
    const badgesRow = document.getElementById("kf-badges-row");
    const pointsBox = document.getElementById("kf-points");

    if (!badge || !badge.isConnected) return;

    badge.classList.remove("enter", "merge");
    badge.classList.add("exit");

    if (MINIMALISTIC) {
        badge.remove();
        if (badgesRow.querySelectorAll(".kf-badge").length === 0) {
            totalPoints = 0;
            renderTotalPoints(pointsBox);
        }
    } else {
        badge.addEventListener("animationend", () => {
            badge.remove();
            if (badgesRow.querySelectorAll(".kf-badge").length === 0) {
                totalPoints = 0;
                renderTotalPoints(pointsBox);
            }
        }, { once: true });
    };
}

const ribbonQueue = [];
let ribbonShowing = false;

function addBadge(badgeName, iconUrl, badgeLevel) {
    ribbonQueue.push({ badgeName: String(badgeName || ""), iconUrl: iconUrl || "", badgeLevel: badgeLevel || "" });
    processRibbonQueue();
}

function processRibbonQueue() {
    if (ribbonShowing) return;
    const next = ribbonQueue.shift();
    if (!next) return;

    ribbonShowing = true;
    showRibbon(next).finally(() => {
        ribbonShowing = false;
        processRibbonQueue();
    });
}

function showRibbon({ badgeName, iconUrl, badgeLevel }) {
    return new Promise((resolve) => {
        if (badgeLevel === 3) {
            A3API.SendAlert("C");
        } else {
            A3API.SendAlert("B");
        }

        const mount = document.getElementById("kf-ribbons");

        const ribbon = document.createElement("div");
        ribbon.className = "kf-ribbon ribbon-enter";

        if (badgeLevel === 1) {
            ribbon.classList.add("ribbon-level-1");
        } else if (badgeLevel === 2) {
            ribbon.classList.add("ribbon-level-2");
        } else {
            ribbon.classList.add("ribbon-level-3");
        }

        const icon = document.createElement("div");
        icon.className = "ribbon-icon";

        if (badgeLevel === 1) {
            icon.classList.add("ribbon-icon-level-1");
        } else if (badgeLevel === 2) {
            icon.classList.add("ribbon-icon-level-2");
        } else {
            icon.classList.add("ribbon-icon-level-3");
        }

        if (iconUrl) {
            const cached = document.imageCache[iconUrl];
            if (cached) {
                applyMask(icon, cached);
            } else {
                A3API.RequestTexture(iconUrl, 64).then(imageContent => {
                    document.imageCache[iconUrl] = imageContent;
                    applyMask(icon, imageContent);
                }).catch(() => { /* fail silently */ });
            }
        }

        const label = document.createElement("span");
        label.textContent = badgeName || "";

        ribbon.appendChild(icon);
        ribbon.appendChild(label);
        mount.replaceChildren(ribbon);

        const minTimer = setTimeout(() => {
            ribbon.classList.remove("ribbon-enter");
            ribbon.classList.add("ribbon-exit");
            ribbon.addEventListener("animationend", () => {
                ribbon.remove();
                resolve();
            }, { once: true });
        }, RIBBON_MIN_SHOW_MS);

        ribbon.addEventListener("DOMNodeRemoved", () => {
            clearTimeout(minTimer);
            resolve();
        }, { once: true });
    });
}

function applyMask(el, dataUrl) {
    el.style.maskImage = `url("${dataUrl}")`;
}

function setSettings(scale, ribbonScale, feedTimeout, minGap, ribbonMinShow, anchorX, anchorY, showIndicator, minimalistic) {
    document.documentElement.style.setProperty('--scale', scale);
    document.documentElement.style.setProperty('--ribbon-scale', ribbonScale);

    document.documentElement.style.setProperty('--anchor-x', `${anchorX}vw`);
    document.documentElement.style.setProperty('--anchor-y', `${anchorY}vh`);

    KILLFEED_TIMEOUT_MS = feedTimeout;
    MIN_GAP_MS = minGap;
    RIBBON_MIN_SHOW_MS = ribbonMinShow;
    SHOW_HIT_INDICATOR = showIndicator;
    MINIMALISTIC = minimalistic;

    if (MINIMALISTIC) {
        document.body.classList.add('minimalistic');
    } else {
        document.body.classList.remove('minimalistic');
    }
}

const indicator = document.querySelector('.hit-indicator');
const indicatorImage = indicator.querySelector('.hit-indicator-image');
A3API.RequestTexture("a3\\ui_f\\data\\igui\\cfg\\cursors\\iconcursorsupport_ca.paa", 64).then(imageContent => {
    indicatorImage.src = imageContent;
});

function hitIndicator() {
    indicator.classList.add('visible');
    clearTimeout(indicator.hideTimeout);
    indicator.hideTimeout = setTimeout(() => {
        indicator.classList.remove('visible');
    }, 500);
}