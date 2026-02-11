# Playwright + axe-core 安装验证

## ✅ 已安装的套件

### 项目级别 (package.json)

```json
{
  "devDependencies": {
    "@playwright/test": "^1.51.0",
    "@axe-core/playwright": "^4.11.0"
  }
}
```

### Skill 级别 (.cursor/skills/playwright-skill/package.json)

```json
{
  "dependencies": {
    "playwright": "^1.57.0",
    "@axe-core/playwright": "^4.11.0"
  }
}
```

---

## 🧪 验证安装

### 1. 检查 Node Modules

```bash
# 检查项目级别安装
ls node_modules/@playwright/test
ls node_modules/@axe-core/playwright

# 检查 skill 级别安装
ls .cursor/skills/playwright-skill/node_modules/@axe-core/playwright
```

### 2. 检查 Playwright 浏览器

```bash
cd .cursor/skills/playwright-skill
npx playwright --version
```

应显示：`Version 1.57.0`

### 3. 运行测试脚本

**启动开发服务器：**

```bash
npm run dev
```

**运行无障碍测试：**

```bash
cd .cursor/skills/playwright-skill
TARGET_URL=http://localhost:5173 BEAD_ID=test node run.js examples/a11y-test.js
```

**预期输出：**

```
✅ Passed: 20 rules
⚠️  Incomplete: 0 rules
❌ Violations: 0 issues

🎉 SUCCESS: No accessibility violations found!
```

**运行截图测试：**

```bash
cd .cursor/skills/playwright-skill
TARGET_URL=http://localhost:5173 BEAD_ID=test node run.js examples/screenshot-test.js
```

**预期输出：**

```
✅ Screenshot saved: .../test-current.png
📋 FIRST RUN - BASELINE CREATED
📐 Testing mobile (375x667)
   ✅ Saved: .../test-mobile.png
📐 Testing tablet (768x1024)
   ✅ Saved: .../test-tablet.png
📐 Testing desktop (1920x1080)
   ✅ Saved: .../test-desktop.png
```

---

## 📂 生成的文件

测试运行后，应该会创建以下文件：

```
memory-bank/snapshots/
├── test-baseline.png    # 基线截图
├── test-current.png     # 当前截图
├── test-mobile.png      # 移动端视图 (375x667)
├── test-tablet.png      # 平板视图 (768x1024)
└── test-desktop.png     # 桌面视图 (1920x1080)
```

---

## 🔧 整合到 生成工作流程

这些工具已经整合到 `/code validate` 命令中。参见：

- [.cursor/commands/code.md](./../commands/code.md) - 生成工作流程文档
- [examples/README.md](./examples/README.md) - 测试脚本使用指南

---

## 🎯 快速测试命令

在项目根目录执行：

```bash
# 1. 启动开发服务器（如果还未启动）
npm run dev &

# 2. 无障碍测试
TARGET_URL=http://localhost:5173 BEAD_ID=test \
  cd .cursor/skills/playwright-skill && node run.js examples/a11y-test.js

# 3. 视觉回归测试
TARGET_URL=http://localhost:5173 BEAD_ID=test \
  cd .cursor/skills/playwright-skill && node run.js examples/screenshot-test.js
```

---

## ❓ 常见问题

### 浏览器未安装

**错误：** `browserType.launch: Executable doesn't exist`

**解决方案：**

```bash
cd .cursor/skills/playwright-skill
npm run setup
```

### Module not found

**错误：** `Cannot find module '@axe-core/playwright'`

**解决方案：**

```bash
cd .cursor/skills/playwright-skill
npm install
```

### 权限错误

**错误：** `EACCES: permission denied`

**解决方案：**

```bash
chmod +x .cursor/skills/playwright-skill/run.js
```

---

## 📚 相关文档

- [SKILL.md](./SKILL.md) - Playwright Skill 完整指南
- [examples/README.md](./examples/README.md) - 测试脚本文档
- [API_REFERENCE.md](./API_REFERENCE.md) - Playwright API 参考
- [@axe-core/playwright](https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright) - 官方文档
