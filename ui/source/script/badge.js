document.imageCache = new Map();
function setImage(imageUrl, element) {
    try {
        if (imageUrl) {
            if (document.imageCache.has(imageUrl)) {
                const img = document.imageCache.get(imageUrl);
                element.style.setProperty('--icon', `url('${img}')`);
                return;
            }

            A3API.RequestTexture(imageUrl, 64).then(img => {
                document.imageCache.set(imageUrl, img);
                element.style.setProperty('--icon', `url('${img}')`);
            });
        }
    } catch { }
}

function setBadges(badgesInput = [], selectedBadgeName = "") {
    const root = document.querySelector(".badge-content");
    if (!root) return;

    const el = (tag, className, attrs = {}) => {
        const node = document.createElement(tag);
        if (className) node.className = className;
        for (const [k, v] of Object.entries(attrs)) {
            if (k === "text") node.textContent = v;
            else node.setAttribute(k, v);
        }
        return node;
    };
    const setStyleVars = (node, vars = {}) => {
        for (const [k, v] of Object.entries(vars)) node.style.setProperty(k, v);
    };

    root.replaceChildren();
    const selectedRegion = el("div", "selected-wrap", {
        "aria-live": "polite",
        "aria-atomic": "true",
    });
    const grid = el("div", "badge-grid", { role: "list" });
    root.append(selectedRegion, grid);

    let selectedIndex = badgesInput.findIndex((b) => b[2] === selectedBadgeName);
    if (selectedIndex < 0) selectedIndex = 0;
    if (!badgesInput.length) selectedIndex = -1; // no badges case

    const renderEmptySelected = () => {
        const wrapper = el("div", "selected-badge");
        const left = el("div", "sb-left");
        const icon = el("div", "icon-mask lg");
        setStyleVars(icon, { "--badge-color": "#666", "--icon": "url('')" });
        left.append(icon);

        const right = el("div", "sb-right");
        right.append(
            el("div", "sb-name", { text: "No badges yet" }),
            el("div", "sb-meta").appendChild(
                (() => {
                    const span = el("span", "count", { text: "Earn some to get started" });
                    return span;
                })()
            ).parentNode
        );

        wrapper.append(left, right);
        selectedRegion.replaceChildren(wrapper);
    };

    const renderSelected = (index) => {
        if (!badgesInput.length || index < 0) {
            renderEmptySelected();
            return;
        }

        const [color, iconUrl, name, count, description] = badgesInput[index];

        const wrapper = el("div", "selected-badge");
        setStyleVars(wrapper, { "--badge-color": color });

        const left = el("div", "sb-left");
        const icon = el("div", "icon-mask lg");
        setStyleVars(icon, { "--badge-color": color });

        left.append(icon);

        try {
            if (iconUrl) {
                setImage(iconUrl, icon);
            }
        } catch { }

        const right = el("div", "sb-right");
        let displayName = name;
        if (description) {
            displayName += ` - ${description}`;
        }
        const title = el("div", "sb-name", { text: displayName });

        const meta = el("div", "sb-meta");
        const dot = el("span", "dot");
        setStyleVars(dot, { color, background: color });
        const owned = el("span", "count", { text: `${count} earned` });
        meta.append(dot, owned);

        right.append(title, meta);
        wrapper.append(left, right);
        selectedRegion.replaceChildren(wrapper);

        // Toggle selected state in grid
        Array.from(grid.children).forEach((child, i) => {
            child.classList.toggle("is-selected", i === index);
            child.setAttribute("aria-selected", i === index ? "true" : "false");
        });
    };

    const makeCard = ([color, iconUrl, name, count], index) => {
        const button = el("button", "badge-card", {
            type: "button",
            role: "listitem",
            "aria-label": `${name}, ${count} earned`,
        });
        setStyleVars(button, { "--badge-color": color });

        const icon = el("div", "icon-mask");
        setStyleVars(icon, { "--badge-color": color, "--icon": `url('${iconUrl || ""}')` });

        const label = el("div", "label", { text: name });
        const countPill = el("div", "count-pill", { text: String(count) });

        button.append(icon, label, countPill);

        const activate = () => {
            renderSelected(index);
            A3API.SendAlert(name);
        };
        button.addEventListener("click", activate);
        button.addEventListener("keydown", (e) => {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                activate();
            }
        });

        try {
            if (iconUrl) {
                setImage(iconUrl, icon);
            }
        } catch { }

        return button;
    };

    // Populate grid efficiently
    grid.replaceChildren();
    const frag = document.createDocumentFragment();
    badgesInput.forEach((badge, i) => frag.appendChild(makeCard(badge, i)));
    grid.appendChild(frag);

    renderSelected(selectedIndex);
}