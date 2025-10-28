const { test, expect } = require('@playwright/test');

test('homepage can load', async ({ page }) => {
  await page.goto('file://' + __dirname + '/../offline_army_builder.html');
  await page.screenshot({ path: 'test-results/load-test.png' });
});
