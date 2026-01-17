# 📦 Installation Guide

## Quick Install (.pkg Installer)

### Option 1: Using the Installer Script (Recommended)

```bash
cd macOS-security-checker
chmod +x build_pkg_installer.sh
./build_pkg_installer.sh
```

This will:
1. Build the application from source
2. Create a macOS .pkg installer
3. Save it to `dist/macOS-security-checker-1.0.0.pkg`
4. Display installation instructions

### Option 2: Manual Installation from .pkg

1. **Download** the latest `.pkg` installer from releases
2. **Double-click** to open the installer
3. **Follow** the on-screen prompts
4. **Launch** from Applications folder

### After Installation

The app will be installed to `/Applications/macOS-security-checker.app`

**Launch it:**
- Via Spotlight: Press `Cmd+Space` and type "Security"
- Via Finder: Go to Applications and double-click
- Via Terminal:
  ```bash
  open /Applications/macOS-security-checker.app
  ```

---

## What Gets Installed

### Application
```
/Applications/macOS-security-checker.app/
  └── Contents/
      ├── MacOS/
      │   └── macOS-security-checker (executable)
      ├── Info.plist
      └── Resources/
```

### Configuration Directory
```
~/.security-checker/
  └── config.json (default settings)
```

### Document Storage
```
~/Documents/Security Reports/
  └── (generated reports saved here)
```

---

## System Requirements

- **macOS:** 12.0 or later
- **Architecture:** Intel or Apple Silicon
- **Disk Space:** ~50 MB minimum
- **Memory:** 100 MB recommended
- **Permissions:** Full Disk Access (requested at first run)

---

## Installation Options

### Via .pkg Installer (User-Friendly)
**Best for:** Most users

```bash
./build_pkg_installer.sh
open dist/macOS-security-checker-1.0.0.pkg
```

**Advantages:**
- Easy point-and-click installation
- Automatic setup
- Can be distributed to others
- Standard macOS installation process

### Via Command Line
**Best for:** Developers and automation

```bash
swift build -c release
sudo /path/to/executable /Applications/
```

### Manual Installation
**Best for:** Testing/Development

```bash
swift build -c release
mkdir -p ~/Applications
cp .build/release/macOS-security-checker ~/Applications/
./~/Applications/macOS-security-checker
```

---

## Granting Permissions

### Full Disk Access (Recommended)
Some checks require Full Disk Access for accurate results.

1. System Settings → Privacy & Security
2. Scroll down to "Full Disk Access"
3. Click the + button
4. Navigate to Applications and select macOS Security Checker
5. Click "Open"

### Password Prompt
You may be prompted for your password when running certain security checks that require elevated privileges. This is normal and expected.

---

## Verification

### Verify Installation
```bash
# Check if app is installed
ls -la /Applications/macOS-security-checker.app

# Check executable
file /Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker

# Run a test
/Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker --help
```

### Verify Configuration
```bash
# Check config directory
ls -la ~/.security-checker

# View configuration
cat ~/.security-checker/config.json
```

---

## Troubleshooting

### "App is damaged" Error
This can happen with unsigned apps. Try:

```bash
# Remove quarantine attribute
xattr -d com.apple.quarantine /Applications/macOS-security-checker.app
```

### Permission Denied
```bash
# Fix file permissions
chmod +x /Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker
```

### "macOS cannot verify developer"
1. Right-click the app
2. Select "Open"
3. Click "Open" in the dialog

### Installation Failed
- Ensure you have admin privileges
- Check available disk space
- Try manual installation instead

---

## Uninstallation

### Remove Application
```bash
rm -rf /Applications/macOS-security-checker.app
```

### Remove Configuration
```bash
rm -rf ~/.security-checker
```

### Remove Reports
```bash
rm -rf ~/Documents/Security\ Reports/
```

### Complete Removal
```bash
rm -rf /Applications/macOS-security-checker.app ~/.security-checker ~/Documents/Security\ Reports/
```

---

## Creating Custom Installers

### For Distribution
```bash
# Build custom .pkg with your branding
./build_pkg_installer.sh

# The .pkg can be:
# - Distributed to teams
# - Hosted on servers
# - Deployed via MDM
# - Included in imaging
```

### For Enterprise MDM
The .pkg installer is compatible with:
- Apple Device Enrollment
- MDM solutions (Jamf, Kandji, etc.)
- System deployment tools

### Configuration
Pre-populate settings by editing `config.json`:

```json
{
  "scanInterval": 3600,
  "alertOnChanges": true,
  "remediationLevel": "automatic",
  "complianceBenchmark": "CIS",
  "mdmEnabled": true
}
```

---

## Updating

### Check for Updates
```bash
# Check version in app or:
/Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker --version
```

### Update Process
1. Download new .pkg installer
2. Run it (will upgrade existing installation)
3. Settings are preserved automatically

### Manual Update
```bash
# Back up configuration
cp ~/.security-checker/config.json ~/.security-checker/config.json.backup

# Build new version
swift build -c release

# Replace app
cp -r .build/release/macOS-security-checker /Applications/macOS-security-checker.app
```

---

## Support

- **Issues:** GitHub Issues
- **Questions:** GitHub Discussions
- **Installation help:** See troubleshooting section above
- **Email:** security@example.com

---

## Next Steps

1. ✅ Install the application
2. 📖 Read [README.md](README.md)
3. 🚀 Run your first security assessment
4. 📊 Export your first report
5. ⚙️ Configure settings

---

**Happy securing! 🛡️**
