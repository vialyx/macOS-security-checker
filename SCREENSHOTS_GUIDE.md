# 📸 How to Add Screenshots

The README now has a **Screenshots** section! Here's how to add them:

## Steps to Capture and Add Screenshots:

### 1. **Open the App**
```bash
open /Applications/macOS-security-checker.app
```

### 2. **Capture Main Dashboard**
- Let the app fully load
- Run a security scan to populate results
- Use `Cmd + Shift + 4` to capture the window
- Drag to select the entire application window
- Save the image as `dashboard.png`

### 3. **Capture Scanning Status**
- Click "Run Security Check" button
- Immediately capture while spinner shows "Scanning..."
- Save as `scanning.png`

### 4. **Capture Results**
- Wait for scan to complete
- Scroll down to show more checks
- Capture and save as `results.png`

### 5. **Move Files**
```bash
# Move your screenshots to the screenshots folder
mv ~/Desktop/dashboard.png screenshots/
mv ~/Desktop/scanning.png screenshots/
mv ~/Desktop/results.png screenshots/
```

### 6. **Commit and Push**
```bash
git add screenshots/
git commit -m "Add application screenshots"
git push
```

## PayPal Setup

**⚠️ Important**: Update the PayPal donation link in the README:

1. Replace `YOUR_BUTTON_ID` in the README with your actual PayPal Button ID
2. Or use your PayPal.me link instead

Two options:

**Option A: PayPal Donate Button**
```markdown
[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/donate/?hosted_button_id=YOUR_BUTTON_ID)
```

**Option B: PayPal.me Link** (simpler)
```markdown
[![Donate with PayPal](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://paypal.me/yourusername)
```

**Option C: Direct link text**
```markdown
**Donate**: [PayPal](https://www.paypal.com/donate/?hosted_button_id=YOUR_BUTTON_ID) | [Stripe](https://your-stripe-link.com)
```

---

**Done!** Your README is now updated with donation info and screenshot references. ✅
