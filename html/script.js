const resourceName = window.GetParentResourceName ? GetParentResourceName() : 'horse-ranch';

function post(endpoint, data) {
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data || {})
    });
}

const app = document.getElementById('app');
const balanceEl = document.getElementById('balance');
const horseListEl = document.getElementById('horseList');
const breedListEl = document.getElementById('breedList');
const toastEl = document.getElementById('toast');
const trainingOverlay = document.getElementById('trainingOverlay');
const tapCountEl = document.getElementById('tapCount');
const progressFill = document.getElementById('progressFill');
const breedSelectA = document.getElementById('breedSelectA');
const breedSelectB = document.getElementById('breedSelectB');

let currentHorses = {};
let breedSelection = { a: null, b: null };

document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
        document.querySelectorAll('.tab-content').forEach(c => c.classList.add('hidden'));
        btn.classList.add('active');
        document.getElementById(btn.dataset.tab + 'Tab').classList.remove('hidden');
    });
});

function statBar(label, value) {
    return `<div class="stat-row"><span class="label">${label}</span>
    <div class="stat-bar"><div class="stat-fill" style="width:${value}%"></div></div>
    <span>${value}</span></div>`;
}

function renderHorses() {
    horseListEl.innerHTML = '';
    const ids = Object.keys(currentHorses);
    if (ids.length === 0) {
        horseListEl.innerHTML = '<p class="hint">You don\'t own any horses yet — check the Buy tab.</p>';
    } else {
        ids.forEach(id => {
            const h = currentHorses[id];
            const card = document.createElement('div');
            card.className = 'horse-card';
            card.innerHTML = `
                <div class="name">${h.name}</div>
                ${statBar('Speed', h.speed)}
                ${statBar('Stamina', h.stamina)}
                ${statBar('Temperament', h.temperament)}
                ${statBar('Condition', h.conditionStamina ?? 100)}
                <div class="card-actions">
                    <button data-action="train" data-id="${id}">Train</button>
                    <button data-action="sell" data-id="${id}">Sell</button>
                </div>
            `;
            horseListEl.appendChild(card);
        });

        horseListEl.querySelectorAll('button').forEach(btn => {
            btn.addEventListener('click', () => {
                const id = btn.dataset.id;
                if (btn.dataset.action === 'train') post('startTraining', { horseId: id });
                else if (btn.dataset.action === 'sell') post('sellHorse', { horseId: id });
            });
        });
    }
    renderBreedSlots();
}

function renderBreedSlots() {
    breedSelectA.textContent = breedSelection.a ? currentHorses[breedSelection.a].name : 'Select Parent A';
    breedSelectB.textContent = breedSelection.b ? currentHorses[breedSelection.b].name : 'Select Parent B';
}

function pickBreedSlot(slot) {
    const ids = Object.keys(currentHorses);
    if (ids.length === 0) return;
    const other = slot === 'a' ? breedSelection.b : breedSelection.a;
    const candidates = ids.filter(id => id !== other);
    if (candidates.length === 0) return;
    const current = breedSelection[slot];
    let nextIndex = 0;
    if (current) {
        const idx = candidates.indexOf(current);
        nextIndex = (idx + 1) % candidates.length;
    }
    breedSelection[slot] = candidates[nextIndex];
    renderBreedSlots();
}

breedSelectA.addEventListener('click', () => pickBreedSlot('a'));
breedSelectB.addEventListener('click', () => pickBreedSlot('b'));

document.getElementById('confirmBreed').addEventListener('click', () => {
    if (!breedSelection.a || !breedSelection.b) return;
    post('breedHorses', { parentA: breedSelection.a, parentB: breedSelection.b });
});

function renderBreedList(breeds) {
    breedListEl.innerHTML = '';
    breeds.forEach((b, i) => {
        const card = document.createElement('div');
        card.className = 'horse-card';
        card.innerHTML = `
            <div class="name">${b.name} — $${b.basePrice}</div>
            <div class="card-actions">
                <button data-index="${i}">Buy</button>
            </div>
        `;
        breedListEl.appendChild(card);
    });
    breedListEl.querySelectorAll('button').forEach(btn => {
        btn.addEventListener('click', () => {
            post('buyHorse', { breedIndex: parseInt(btn.dataset.index, 10) + 1 });
        });
    });
}

function showToast(message, type) {
    toastEl.textContent = message;
    toastEl.className = 'toast ' + (type || '');
    toastEl.classList.remove('hidden');
    setTimeout(() => toastEl.classList.add('hidden'), 2500);
}

window.addEventListener('message', (event) => {
    const data = event.data;
    switch (data.action) {
        case 'open':
            app.classList.remove('hidden');
            renderBreedList(data.breeds);
            break;
        case 'close':
            app.classList.add('hidden');
            break;
        case 'balance':
            balanceEl.textContent = data.amount;
            break;
        case 'horses':
            currentHorses = data.horses || {};
            renderHorses();
            break;
        case 'notify':
            showToast(data.message, data.type);
            break;
        case 'trainingStart': {
            trainingOverlay.classList.remove('hidden');
            tapCountEl.textContent = '0';
            progressFill.style.width = '0%';
            const start = Date.now();
            const dur = data.duration;
            const interval = setInterval(() => {
                const pct = Math.min(100, ((Date.now() - start) / dur) * 100);
                progressFill.style.width = pct + '%';
                if (pct >= 100) {
                    clearInterval(interval);
                    setTimeout(() => trainingOverlay.classList.add('hidden'), 400);
                }
            }, 100);
            break;
        }
        case 'trainingTap':
            tapCountEl.textContent = data.taps;
            break;
    }
});

document.getElementById('closeBtn').addEventListener('click', () => post('close'));
document.addEventListener('keyup', (e) => { if (e.key === 'Escape') post('close'); });
