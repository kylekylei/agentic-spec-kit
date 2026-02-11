/**
 * Visual Regression Testing with Screenshots
 *
 * Usage:
 *   BEAD_ID=bead-001 cd .cursor/skills/playwright-skill && node run.js examples/screenshot-test.js
 *
 * Environment Variables:
 *   TARGET_URL - URL to test (default: http://localhost:5173)
 *   BEAD_ID - Current bead ID (required for file naming)
 *   SNAPSHOT_DIR - Directory for screenshots (default: ../../../memory-bank/snapshots)
 */

const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

// Configuration
const TARGET_URL = process.env.TARGET_URL || 'http://localhost:5173';
const BEAD_ID = process.env.BEAD_ID || 'bead-unknown';
const SNAPSHOT_DIR = process.env.SNAPSHOT_DIR || path.resolve(__dirname, '../../../memory-bank/snapshots');

(async () => {
  console.log('📸 Starting Visual Regression Test');
  console.log(`📍 Target URL: ${TARGET_URL}`);
  console.log(`🔖 Bead ID: ${BEAD_ID}`);
  console.log(`📁 Snapshot Directory: ${SNAPSHOT_DIR}\n`);

  // Ensure snapshot directory exists
  if (!fs.existsSync(SNAPSHOT_DIR)) {
    fs.mkdirSync(SNAPSHOT_DIR, { recursive: true });
    console.log('✅ Created snapshot directory\n');
  }

  // Launch browser (visible for debugging)
  const browser = await chromium.launch({
    headless: false,
    slowMo: 50
  });

  const page = await browser.newPage();

  try {
    // Set viewport size
    await page.setViewportSize({ width: 1280, height: 720 });
    console.log('📐 Viewport: 1280x720\n');

    // Navigate to target
    console.log('🌐 Loading page...');
    await page.goto(TARGET_URL, {
      waitUntil: 'networkidle',
      timeout: 10000
    });
    console.log('✅ Page loaded successfully\n');

    // Take screenshot
    const currentPath = path.join(SNAPSHOT_DIR, `${BEAD_ID}-current.png`);
    const baselinePath = path.join(SNAPSHOT_DIR, `${BEAD_ID}-baseline.png`);

    console.log('📸 Capturing screenshot...');
    await page.screenshot({
      path: currentPath,
      fullPage: true
    });
    console.log(`✅ Screenshot saved: ${currentPath}\n`);

    // Check for baseline
    if (!fs.existsSync(baselinePath)) {
      // First run - create baseline
      fs.copyFileSync(currentPath, baselinePath);
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('📋 FIRST RUN - BASELINE CREATED');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      console.log(`✅ Baseline saved: ${baselinePath}`);
      console.log('\nℹ️  Future runs will compare against this baseline.\n');
    } else {
      // Subsequent runs - compare with baseline
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      console.log('🔍 VISUAL COMPARISON');
      console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      console.log('📋 Baseline:', baselinePath);
      console.log('📄 Current: ', currentPath);
      console.log('\nℹ️  Please manually compare the images to verify changes are expected.\n');

      // Get file sizes for basic comparison
      const baselineStats = fs.statSync(baselinePath);
      const currentStats = fs.statSync(currentPath);
      const sizeDiff = ((currentStats.size - baselineStats.size) / baselineStats.size * 100).toFixed(2);

      console.log('📊 File Size Comparison:');
      console.log(`   Baseline: ${(baselineStats.size / 1024).toFixed(2)} KB`);
      console.log(`   Current:  ${(currentStats.size / 1024).toFixed(2)} KB`);
      console.log(`   Difference: ${sizeDiff > 0 ? '+' : ''}${sizeDiff}%\n`);

      if (Math.abs(sizeDiff) > 10) {
        console.log('⚠️  WARNING: File size difference > 10%');
        console.log('   This may indicate significant visual changes.\n');
      }
    }

    // Additional test scenarios (optional)
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📱 RESPONSIVE TESTING');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    const viewports = [
      { name: 'mobile', width: 375, height: 667 },
      { name: 'tablet', width: 768, height: 1024 },
      { name: 'desktop', width: 1920, height: 1080 }
    ];

    for (const viewport of viewports) {
      console.log(`📐 Testing ${viewport.name} (${viewport.width}x${viewport.height})`);
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.waitForTimeout(500); // Allow layout to settle

      const screenshotPath = path.join(SNAPSHOT_DIR, `${BEAD_ID}-${viewport.name}.png`);
      await page.screenshot({
        path: screenshotPath,
        fullPage: true
      });
      console.log(`   ✅ Saved: ${screenshotPath}`);
    }

    console.log('\n✅ All screenshots captured successfully!\n');

    // Keep browser open for a moment
    console.log('⏳ Browser will close in 2 seconds...');
    await page.waitForTimeout(2000);

    await browser.close();
    process.exit(0);

  } catch (error) {
    console.error('\n❌ ERROR:', error.message);
    await browser.close();
    process.exit(1);
  }
})();
