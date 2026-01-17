# Quick Start Guide

## 🚀 Getting Started

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0+ (Swift 5.9+)
- Command Line Tools: `xcode-select --install`

### Build in 30 Seconds
```bash
git clone https://github.com/yourusername/macOS-security-checker.git
cd macOS-security-checker
swift build -c release
```

### Run Immediately
```bash
./.build/release/macOS-security-checker
```

---

## 📖 What's Included

### 50+ Security Checks
✅ **11 Assessment Categories:**
1. OS & Firmware Hardening
2. User Authentication & Access Control
3. Disk & Data Protection
4. Application Security & Execution
5. Permissions & Privacy
6. Network Security
7. Malware & Threat Protection
8. System Integrity & Tamper Protection
9. Logging, Monitoring & Auditing
10. Compliance & Posture Assessment
11. User Education & UX

### Real-Time Menu Bar App
- Shield icon shows security status
- Green/Orange/Red indicator
- Expandable categories
- One-click access to remediation

### Complete Reports
- JSON export for automation
- CSV for spreadsheets
- HTML for viewing/sharing
- Security score (0-100%)

### Developer-Friendly
- 2,800+ lines of documented Swift
- Clear separation of concerns
- Easy to add new checks
- Full source code included

---

## 📊 Assessment Output

When you run the app, you'll see:

```
✅ Passed: 28
⚠️  Warnings: 8
❌ Failed: 3
📈 Overall Score: 78.5%
```

### Sample Check Output
```
🔹 OS & Firmware Hardening
  ✅ Latest macOS Version
     → Check software updates
  ✅ Automatic Security Updates
     → System Settings → General → Software Update
  ❌ Firmware Password
     → Restart → Hold Cmd+R → Enable in Firmware
```

---

## 🔍 Understanding Results

### Status Indicators
- **✅ Pass (Green)** - Security control is properly configured
- **⚠️ Warning (Orange)** - Control partially configured or needs attention
- **❌ Fail (Red)** - Security vulnerability detected
- **❓ Unknown** - Cannot determine status on this system

### Severity Levels
- **5/5 - Critical** - Must be enabled for security
- **4/5 - High** - Important protection
- **3/5 - Medium** - Recommended configuration
- **2/5 - Low** - Suggested improvement
- **1/5 - Minor** - Nice to have

### Enforceable vs Observable
- **Enforceable ✓** - Can be configured/enforced via MDM
- **Observable ⚠️** - Can only be detected/monitored

---

## 📁 Reports

Reports are saved to: `~/Documents/Security Reports/`

### Formats Available
1. **JSON** - For API integration and automation
2. **CSV** - For Excel/spreadsheet analysis
3. **HTML** - For viewing in browser

### Export Command
```bash
# Generated automatically during scan
# Or export from UI menu
```

---

## ⚙️ Configuration

Edit `~/.security-checker/config.json`:

```json
{
  "scanInterval": 3600,
  "alertOnChanges": true,
  "remediationLevel": "guided",
  "complianceBenchmark": "CIS",
  "mdmEnabled": false
}
```

### Settings
- **scanInterval** - Seconds between scans (300-86400)
- **alertOnChanges** - Notify on security changes
- **remediationLevel** - manual | guided | automatic
- **complianceBenchmark** - CIS | NIST_800-53 | SOC2 | etc
- **mdmEnabled** - Enable MDM integration

---

## 🛠️ Common Tasks

### View Full Report
```bash
# Check details in menu bar app
# Click on category to expand
# Click on check for full details
```

### Export for Compliance
```bash
# JSON export (best for processing)
# Reports saved to ~/Documents/Security Reports/
# Use for compliance documentation
```

### Fix a Security Issue
```bash
# 1. Click on failed check in menu bar app
# 2. Read remediation steps
# 3. Follow instructions or
# 4. Click "Fix Issue" for auto-remediation (coming soon)
```

### Configure Scanning
```bash
# Edit ~/.security-checker/config.json
# Change scanInterval (seconds)
# Restart app
```

### Check CLI Output
```bash
# Run from terminal for detailed output
./.build/release/macOS-security-checker

# Or pipe to file
./.build/release/macOS-security-checker > report.txt
```

---

## 🆘 Troubleshooting

### App Won't Launch
```bash
# Check permissions
ls -la ~/.security-checker/

# Grant Full Disk Access:
# System Settings → Privacy & Security → Full Disk Access → Add App

# Try rebuilding
swift build -c release
```

### Checks Show "Unknown"
```bash
# Ensure macOS 12.0+
sw_vers -productVersion

# Verify command-line tools installed
xcode-select --install

# Check if command is available
which csrutil
which fdesetup
```

### Permission Denied Errors
```bash
# Some checks need elevation
# App will prompt for password
# Enter your administrator password when asked

# Or grant Full Disk Access in System Settings
```

### Slow Scan Performance
```bash
# First scan: 30 seconds (builds cache)
# Subsequent scans: 10-15 seconds
# If slower, check system load
```

---

## 📚 Learning More

### Documentation Files
- **README.md** - Full user guide
- **BUILD.md** - Detailed build instructions
- **DEVELOPMENT.md** - Developer API reference
- **PROJECT_SUMMARY.md** - Architecture overview
- **ROADMAP.md** - Future plans and timeline

### Getting Help
1. Check documentation files
2. Review source code comments
3. Check GitHub Issues
4. Open a new issue with details

### Contributing
Want to add checks or improvements?
1. Read DEVELOPMENT.md
2. Fork the repository
3. Make your changes
4. Submit a pull request

---

## 🔐 Security & Privacy

### What the App Does
✅ Checks your local security configuration
✅ Saves reports locally on your computer
✅ Uses standard macOS security APIs
✅ Never sends data externally (unless you share reports)

### What the App Doesn't Do
❌ Store passwords or sensitive data
❌ Transmit information to servers
❌ Install software without permission
❌ Make changes without user approval

### Elevation & Sudoers
- App requests sudo only when needed
- User must approve each elevation
- All elevated operations are logged
- Password never saved

---

## 💡 Tips & Tricks

### Keyboard Shortcuts
- **Cmd+R** - Run checks
- **Cmd+E** - Export report
- **Cmd+,** - Settings
- **Cmd+Q** - Quit app

### Viewing Reports
```bash
# Open HTML report in browser
open ~/Documents/Security\ Reports/Security_Report_*.html

# View JSON with formatting
cat ~/Documents/Security\ Reports/Security_Report_*.json | python3 -m json.tool
```

### Automating Checks
```bash
# Run checks in background every hour
# Configure in app settings or via cron:
0 * * * * /path/to/macOS-security-checker
```

### Comparing Scans
```bash
# Compare two reports
# Export both as JSON
# Use diff tool to see changes
diff report1.json report2.json
```

---

## 🎯 Next Steps

1. **Install** - Build and launch the app
2. **Scan** - Run initial security assessment
3. **Review** - Examine results and remediation steps
4. **Fix** - Address critical findings
5. **Monitor** - Schedule regular scans
6. **Export** - Generate reports for compliance

---

## 📞 Support Resources

- **Website:** (Coming soon)
- **Email:** security@example.com
- **GitHub:** github.com/yourusername/macOS-security-checker
- **Issues:** GitHub Issues page
- **Discussions:** GitHub Discussions

---

## 📜 License & Legal

This project is provided under the MIT License.

### Disclaimer
This tool is for authorized security assessment only. Unauthorized access to computer systems is illegal. Always ensure you have proper authorization before running security checks on systems you don't own.

### Liability
The developers of macOS Security Checker make no warranties, express or implied, about the accuracy or completeness of the security assessments. Use at your own risk.

---

## 🚀 Version Info

- **Current Version:** 1.0.0 (Foundation Release)
- **macOS Support:** 12.0+
- **Swift Version:** 5.9+
- **Architecture:** Intel & Apple Silicon
- **Release Date:** January 2025

---

## 🙏 Thank You!

We appreciate your interest in macOS Security Checker. Your feedback and contributions help us improve security practices across the macOS community.

**Happy securing! 🛡️**

---

## Appendix: Command Reference

### Building
```bash
swift build               # Debug build
swift build -c release   # Release build
swift build -v          # Verbose output
```

### Running
```bash
./.build/release/macOS-security-checker
swift run macOS-security-checker
open macOS-security-checker.app
```

### Testing
```bash
swift test
swift test -v
swift test --filter SecurityCheckerTests.OSHardeningTests
```

### Code Quality
```bash
swift build -c release -Xswiftc -strict-concurrency=complete
swiftlint                # Requires: brew install swiftlint
swift-format -i -r .    # Requires: brew install swift-format
```

### Troubleshooting
```bash
swift build --clean
rm -rf .build
xcode-select --reset
xcode-select --install
```

---

**For more information, see the complete documentation files included in the repository.**
