# Extension API Reference

## SKILL.md Schema

```yaml
---
description: "當使用者要求 [觸發條件] 時使用此 skill"
alwaysApply: false
---
```

### 結構

```markdown
# [Skill Name]

## 執行步驟（≤10 條，每條 ≤2 行）

## 驗證標準（具體、可執行的檢查項）

## refs/ 內檔案索引（一行一檔，標注用途）
```

### 目錄結構

```
templates/skills/<skill-name>/
├── SKILL.md           # 必要：觸發條件 + 執行步驟
├── references/        # 可選：詳細參考文件（冷層）
├── templates/         # 可選：模板檔案
└── data/              # 可選：靜態資料
```

## Agent Schema

```yaml
---
name: Agent Name
description: One-line description
color: "#hex"
skills:
  - skill-a
  - skill-b
---
```

### 結構

```markdown
# [Agent Name]

## Role（角色定義表格）

## Abilities（意圖 → Skill 對應表）

## Tool Rules（工具使用限制）
```

## Rule (.mdc) Schema

```yaml
---
alwaysApply: true|false
description: "觸發條件描述（alwaysApply: false 時必要）"
globs: "*.ts"          # 可選：檔案匹配
---
```

## skill-registry.yml

新 Skill 必須在此註冊：

```yaml
categories:
  <category_name>:
    label: "Category Label"
    detect:
      files: [Dockerfile]
      deps: [react]
    skills:
      - skill-name
    agents:
      - name: agent-name
        description: "..."
        skills: [skill-a, skill-b]
```
