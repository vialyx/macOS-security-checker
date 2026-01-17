# Screenshots

This directory contains screenshots of the macOS Security Checker application.

## How to Capture Screenshots

To update the screenshots, follow these steps:

### 1. Main Dashboard
- Open the app
- Resize window to approximately 900x700
- Make sure the app has completed at least one scan
- Capture the main window showing:
  - Status cards (Passed, Warnings, Failed)
  - Overall Security Score
  - Run Security Check button
  - List of security checks
- Save as `dashboard.png`

### 2. Scanning
- Open the app
- Click "Run Security Check" button
- Immediately capture while the spinner is visible and scanning is in progress
- Should show "Scanning..." indicator in top right
- Save as `scanning.png`

### 3. Detailed Results
- After a full scan completes
- Scroll down to show more of the security checks list
- Capture showing:
  - Multiple security checks with different statuses (✅ ⚠️ ❌)
  - Category tags
  - Check descriptions
- Save as `results.png`

## Screenshot Format

- Format: PNG
- Resolution: Capture at native resolution (2x on Retina displays)
- Dimensions: Approximately 1800x1400 pixels (or equivalent)
- Quality: No compression artifacts

## Using macOS Screenshot Tool

```bash
# Press these keys together
Cmd + Shift + 4

# Then select the window area to capture
# Or use Cmd + Shift + 5 for more options
```

## Current Screenshots

- `dashboard.png` - Main application dashboard
- `scanning.png` - Real-time scanning in progress
- `results.png` - Detailed security check results
