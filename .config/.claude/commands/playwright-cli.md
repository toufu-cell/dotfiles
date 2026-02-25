---
description: Automates browser interactions for web testing, form filling, screenshots, and data extraction
allowed-tools: Bash
---

# playwright-cli

Browser automation CLI tool for efficient browser testing with minimal context overhead.

## Quick Start

```bash
playwright-cli open https://example.com/
playwright-cli snapshot
playwright-cli click e3
```

## Core Workflow

1. `open` to navigate to a page
2. `snapshot` to get element refs (YAML format accessibility tree)
3. `click`, `fill`, `type` to interact
4. `screenshot` to capture visual state

## Commands

### Core
```bash
playwright-cli open <url>              # open url
playwright-cli close                   # close the page
playwright-cli click <ref>             # perform click
playwright-cli fill <ref> <text>       # fill text
playwright-cli type <text>             # type text
playwright-cli snapshot                # capture page snapshot (YAML)
playwright-cli screenshot [ref]        # take screenshot (PNG)
```

### Sessions
```bash
playwright-cli --session=<name> open <url>  # open with named session
playwright-cli --session=<name> --headed open <url>  # open with visible browser
playwright-cli session-stop-all             # stop all sessions
```

### DevTools
```bash
playwright-cli tracing-start           # start trace recording
playwright-cli tracing-stop            # stop trace recording
playwright-cli console [min-level]     # list console messages
```

## Typical Test Development Flow

### Step 1: Interactive Exploration
```bash
# Start session with visible browser
playwright-cli --session=test --headed open http://localhost:3000

# Get element refs
playwright-cli --session=test snapshot

# Interact with elements using refs from snapshot
playwright-cli --session=test click e39
playwright-cli --session=test fill e12 "test input"

# Capture screenshot for verification
playwright-cli --session=test screenshot
```

### Step 2: Cleanup
```bash
playwright-cli session-stop-all
rm -rf .playwright-cli/
```

## Working Files

playwright-cli generates files in `.playwright-cli/`:
- `*.yml` - snapshot results (accessibility tree with element refs)
- `*.png` - screenshot captures

Add to `.gitignore`:
```
.playwright-cli/
```

## Notes

- Use `--headed` flag to see the browser window
- Use `--session=<name>` to maintain state across commands
- Element refs (e.g., `e39`) are from `snapshot` output
- After exploration, implement tests with `@playwright/test`
