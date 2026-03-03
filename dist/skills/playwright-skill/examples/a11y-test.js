/**
 * Accessibility Testing with @axe-core/playwright
 *
 * Usage:
 *   cd .cursor/skills/playwright-skill && node run.js examples/a11y-test.js
 *
 * Environment Variables:
 *   TARGET_URL - URL to test (default: http://localhost:5173)
 *   BEAD_ID - Current bead ID for reporting (optional)
 */

const { chromium } = require('playwright');
const AxeBuilder = require('@axe-core/playwright').default;

// Configuration
const TARGET_URL = process.env.TARGET_URL || 'http://localhost:5173';
const BEAD_ID = process.env.BEAD_ID || 'unknown';

(async () => {
  console.log('🚀 Starting Accessibility Test');
  console.log(`📍 Target URL: ${TARGET_URL}`);
  console.log(`🔖 Bead ID: ${BEAD_ID}\n`);

  // Launch browser (visible for debugging)
  const browser = await chromium.launch({
    headless: false,
    slowMo: 100
  });

  // @axe-core/playwright requires using browser.newContext()
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate to target
    console.log('🌐 Loading page...');
    await page.goto(TARGET_URL, {
      waitUntil: 'networkidle',
      timeout: 10000
    });
    console.log('✅ Page loaded successfully\n');

    // Run accessibility scan
    console.log('🔍 Running axe-core accessibility scan...');
    console.log('📋 Standards: WCAG 2.0 Level A, AA & WCAG 2.2 Level AA\n');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag22aa'])
      .analyze();

    // Report results
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 TEST RESULTS');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log(`✅ Passed: ${accessibilityScanResults.passes.length} rules`);
    console.log(`⚠️  Incomplete: ${accessibilityScanResults.incomplete.length} rules`);
    console.log(`❌ Violations: ${accessibilityScanResults.violations.length} issues\n`);

    // Display violations in detail
    if (accessibilityScanResults.violations.length > 0) {
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('❌ VIOLATIONS FOUND');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      accessibilityScanResults.violations.forEach((violation, index) => {
        console.log(`${index + 1}. [${violation.impact.toUpperCase()}] ${violation.id}`);
        console.log(`   📄 ${violation.description}`);
        console.log(`   🔗 ${violation.helpUrl}\n`);

        violation.nodes.forEach((node, nodeIndex) => {
          console.log(`   Element ${nodeIndex + 1}:`);
          console.log(`   🎯 ${node.target.join(' > ')}`);
          console.log(`   💬 ${node.failureSummary}\n`);
        });
      });

      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }

    // Display incomplete checks (for review)
    if (accessibilityScanResults.incomplete.length > 0) {
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('⚠️  INCOMPLETE CHECKS (Manual Review Needed)');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      accessibilityScanResults.incomplete.forEach((item, index) => {
        console.log(`${index + 1}. ${item.id}`);
        console.log(`   📄 ${item.description}`);
        console.log(`   🔗 ${item.helpUrl}\n`);
      });

      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }

    // Final summary
    if (accessibilityScanResults.violations.length === 0) {
      console.log('🎉 SUCCESS: No accessibility violations found!');
      console.log('✅ All WCAG 2.0 A/AA and WCAG 2.2 AA rules passed.\n');
    } else {
      console.log('❌ FAILED: Accessibility violations detected.');
      console.log(`   Please fix ${accessibilityScanResults.violations.length} violation(s) before proceeding.\n`);
    }

    // Keep browser open for a moment
    console.log('⏳ Browser will close in 3 seconds...');
    await page.waitForTimeout(3000);

    await context.close();
    await browser.close();

    // Exit with appropriate code
    process.exit(accessibilityScanResults.violations.length > 0 ? 1 : 0);

  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    await context.close();
    await browser.close();
    process.exit(1);
  }
})();
