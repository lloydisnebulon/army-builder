const fs = require('fs');
const units = require('./units.json');

function generateUnitRow(unit) {
  const specialAbilities = unit.sa ? unit.sa.join('/ ') : '';
  return `
    <tr data-id="${unit.id}" data-nation="${unit.nation}" data-year="${unit.year}" class=" ">
        <td class="sideA"><input type="checkbox" name="sideA" class="addUnit" value="A"  /></td>
        <td class="sideB"><input type="checkbox" name="sideB" class="addUnit" value="B" /></td>
        <td><a href="unit_AAM.aspx?unit=${unit.id}" target="_blank">${unit.name}</a></td>
        <td>
            ${unit.type}<br />
            ${unit.category}
        </td>
        <td>${unit.year}</td>
        <td>
            ${unit.cost}
        </td>
        <td>
            ${unit.defense || ''}<br />
            ${unit.speed || ''}
        </td>
        <td>
            AI ${unit.ai || '-/-/-'}<br />
            AV ${unit.av || '-/-/-'}
        </td>
        <td>${specialAbilities}</td>
    </tr>
  `;
}

fs.readFile('sorce code.html', 'utf8', (err, html) => {
    if (err) {
        console.error(err);
        return;
    }

    const unitRows = units.map(generateUnitRow).join('');
    // This regex is too simple and will fail. I'll fix it in the next step.
    const modifiedHtml = html.replace(/<tbody >\s*<\/tbody>/, `<tbody>${unitRows}</tbody>`);

    fs.writeFile('army_builder_with_units.html', modifiedHtml, (err) => {
        if (err) {
            console.error(err);
            return;
        }
        console.log('army_builder_with_units.html created successfully!');
    });
});
