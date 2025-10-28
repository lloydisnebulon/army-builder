const fs = require('fs');

// Read the template and data files
const template = fs.readFileSync('army builder test 23.1 - offline-ready.html', 'utf8');
const units = fs.readFileSync('units.json', 'utf8');
// faq.json is empty, but we'll read it for completeness. In the future it might have content.
const faqs = fs.readFileSync('faq.json', 'utf8') || '{}'; // Default to empty object if file is empty

// Find the position of the first closing script tag
const firstScriptEnd = template.indexOf('</script>');
if (firstScriptEnd === -1) {
  console.error('Error: Could not find the first closing script tag.');
  process.exit(1);
}

// Find the position of the second closing script tag, starting the search after the first one
const secondScriptEnd = template.indexOf('</script>', firstScriptEnd + 1);
if (secondScriptEnd === -1) {
  console.error('Error: Could not find the second closing script tag.');
  process.exit(1);
}

// Get the rest of the template, starting from after the second closing script tag
const templateAfterScripts = template.substring(secondScriptEnd + '</script>'.length);

// Construct the new, single script block
const newScriptBlock = `<script>
const embeddedUnits = ${units};
const embeddedFaqs = ${faqs};
</script>`;

// Combine the new script block with the rest of the template
const finalHtml = newScriptBlock + templateAfterScripts;

// Write the corrected file
fs.writeFileSync('offline_army_builder.html', finalHtml);

console.log('Successfully generated corrected offline_army_builder.html');
