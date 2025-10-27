const fs = require('fs');
const { JSDOM } = require('jsdom');

function main() {
  const html = fs.readFileSync('sorce code.html', 'utf-8');
  const dom = new JSDOM(html);
  const doc = dom.window.document;

  const units = parseUnitsFromHTML(doc);

  fs.writeFileSync('units.json', JSON.stringify(units, null, 2));
  console.log('All units have been saved to units.json');
}

function parseUnitsFromHTML(doc) {
    const KNOWN_NATIONS = [
    'Australia','Belgium','Bulgaria','Canada','China','Croatia','Finland','France','Germany','Greece','Hungary','Italy','Japan',
    'NZ  New Zealand','Poland','Romania','SA South Africa','Slovakia','UK','USA','USSR','Yugoslavia'
  ];
  const nationSet = new Set();
  const SPECIAL_KEY = 'Support, Fortifications & Obstacles';

  let target = null;
  for (const t of [...doc.querySelectorAll('table')]) {
    if (t.querySelector('a[href*="unit_AAM.aspx"]')) {
      target = t;
      break;
    }
  }
  if (!target) return [];

  const header = [...target.querySelectorAll('thead th, thead td')].map(th => (th.textContent || '').trim().toLowerCase());
  const idx = {
    type: header.findIndex(h => /category|type/i.test(h)),
    year: header.findIndex(h => /year/i.test(h)),
    cost: header.findIndex(h => /cost|points|pts/i.test(h)),
    defspd: header.findIndex(h => /def|speed|def\/spd/i.test(h)),
    aiav: header.findIndex(h => /ai|av|ai\/av/i.test(h)),
    abilities: header.findIndex(h => /abilit|special/i.test(h))
  };

  const units = [];
  let currentNation = '';
  for (const tr of target.querySelectorAll('tbody tr, tr')) {
    const link = tr.querySelector('a[href*="unit_AAM.aspx"]');
    const tds = [...tr.children];

    if (tds.length === 1 && (!link || !tds[0].querySelector('a'))) {
      const text = (tds[0].textContent || '').trim();
      const hit = KNOWN_NATIONS.find(n => new RegExp('^' + n.replace(/\s+/g, '\\s+') + '\\b', 'i').test(text));
      if (hit) {
        currentNation = hit;
        nationSet.add(hit);
        continue;
      }
    }

    if (!link) continue;

    const href = link.getAttribute('href') || '';
    const name = decodeHTML(link.textContent.trim());
    if (!/unit_AAM\.aspx\?/i.test(href) || !name) continue;

    const get = (i) => (i >= 0 && tds[i]) ? tds[i] : null;
    const txt = (el) => (el ? decodeHTML(el.textContent.trim()) : '');
    const clean = (s) => decodeHTML((s || '').replace(/\s+/g, ' ').trim());

    const typeRaw = clean(get(idx.type)?.innerHTML || '');
    const type = typeRaw.replace(/<br\s*\/?>/gi, ' / ').replace(/\s+/g, ' ').trim();
    const year = clean(txt(get(idx.year)));
    const costS = clean(txt(get(idx.cost)));
    const cost = parseFloat(costS.replace(',', '.')) || 0;
    const defSpdRaw = clean(get(idx.defspd)?.innerHTML || '');
    const defSpd = defSpdRaw.replace(/<br\s*\/?>/gi, '|');
    const aiavRaw = clean(get(idx.aiav)?.innerHTML || '');
    const aiav = aiavRaw.replace(/<br\s*\/?>/gi, '|');
    const abRaw = clean(get(idx.abilities)?.innerHTML || '');
    let abilities = abRaw.replace(/<[^>]+>/g, '').trim();

    const def = (defSpd.split('|')[0] || '').replace(/Def/i, '').trim();
    const spd = (defSpd.split('|')[1] || '').replace(/Speed/i, '').trim();
    const ai = (aiav.split('|')[0] || '').replace(/AI/i, '').trim();
    const av = (aiav.split('|')[1] || '').replace(/AV/i, '').trim();

    const base = 'http://www.aamcardbase.com';
    const absolute = href.startsWith('http') ? href : (base + '/' + href.replace(/^\//, ''));
    const isSpecial = /Obstacle|Fortification|Support/i.test(type);
    const id = new URL(absolute).searchParams.get('unit');
    const nation = isSpecial ? SPECIAL_KEY : (currentNation || '');
    if (nation) nationSet.add(nation);
    abilities = decodeHTML(abilities);

    const unit = { id, nation, year, name, href: absolute, type, cost, def, spd, ai, av, abilities };
    units.push(unit);
  }
  return units;
}

function decodeHTML(s) {
  const el = new JSDOM('').window.document.createElement('textarea');
  el.innerHTML = s || '';
  return el.value;
}

main();
