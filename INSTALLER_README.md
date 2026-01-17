# 🎁 macOS Security Checker - Installer

## ✅ .pkg Installer Ready!

The macOS Security Checker is now packaged as a professional macOS installer (.pkg).

### 📦 Installer Details

**File:** `dist/macOS-security-checker-1.0.0.pkg`
**Size:** 87 KB
**Format:** macOS Installer Package (xar archive)
**Requires:** macOS 12.0 or later

---

## 🚀 Quick Installation

### Method 1: Simple Double-Click (Recommended)
1. Navigate to the `dist/` folder
2. Double-click `macOS-security-checker-1.0.0.pkg`
3. Follow the installer wizard
4. Enter your admin password when prompted
5. Done! 🎉

### Method 2: Command Line
```bash
open dist/macOS-security-checker-1.0.0.pkg
```

### Method 3: Silent Installation
```bash
sudo installer -pkg dist/macOS-security-checker-1.0.0.pkg -target /
```

---

## 📍 Installation Locations

After installation, you'll find:

```
/Applications/macOS-security-checker.app/
  └── Contents/
      ├── MacOS/macOS-security-checker (executable)
      ├── Info.plist
      └── Resources/
```

**Configuration Directory:**
```
~/.security-checker/
  └── config.json
```

**Reports Directory:**
```
~/Documents/Security Reports/
  └── (your reports will be saved here)
```

---

## 🔧 What Gets Installed

✅ Compiled Swift executable  
✅ Application bundle structure  
✅ Info.plist with app metadata  
✅ Configuration template  
✅ System validation scripts  

---

## 🎯 Running After Installation

### Via Spotlight Search
1. Press `Cmd + Space`
2. Type "Security Checker"
3. Press Enter

### Via Finder
1. Go to Applications folder
2. Find "macOS Security Checker"
3. Double-click to run

### Via Terminal
```bash
/Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker
```

---

## 🔐 Permissions

The app may request the following permissions:

- **Full Disk Access** (for comprehensive security scans)
- **Admin Password** (for elevated security checks)
- **System Events** (for monitoring system changes)

These are optional but recommended for full functionality.

---

## ✨ Features Included

✅ **50+ Security Checks**
- OS & Firmware checks (SIP, FileVault, Firewall)
- Authentication security (Touch ID, GateKeeper)
- Disk protection & encryption
- Application security & notarization
- Network security & privacy
- Malware protection & detection
- System integrity & code signing
- Logging & audit configuration

✅ **Multiple Report Formats**
- JSON for data analysis
- CSV for spreadsheets
- HTML for web viewing
- Interactive CLI output

✅ **Compliance Frameworks**
- CIS Benchmarks
- NIST 800-53
- NIST 800-171
- SOC 2
- Zero Trust Architecture

---

## 🐛 Troubleshooting

### "Package can't be opened"
```bash
xattr -d com.apple.quarantine dist/macOS-security-checker-1.0.0.pkg
```

### "Cannot verify developer"
1. Right-click the app
2. Select "Open"
3. Click "Open" in the confirmation dialog

### Permission Denied
```bash
sudo chown -R root:wheel /Applications/macOS-security-checker.app
sudo chmod -R 755 /Applications/macOS-security-checker.app
```

### Need to Reinstall
```bash
rm -rf /Applications/macOS-security-checker.app
rm -rf ~/.security-checker
# Then double-click the .pkg file again
```

---

## 📊 Build Information

- **Built with:** Swift 5.9+
- **Target:** macOS 12.0+ (Intel & Apple Silicon)
- **Build Date:** January 2025
- **Version:** 1.0.0

---

## 📖 Next Steps

1. ✅ **Install** the application
2. 📖 **Read** the [README.md](README.md) for full documentation
3. 🚀 **Run** your first security assessment
4. 📊 **Export** your first security report
5. ⚙️ **Configure** custom settings

---

## 🔄 Rebuilding the Installer

To rebuild the .pkg installer from source:

```bash
# From the project root
./build_pkg_installer.sh
```

This will:
1. ✅ Build the release executable
2. ✅ Create the app bundle structure
3. ✅ Generate the .pkg installer
4. ✅ Save to `dist/` directory

---

## 📝 Installer Script Details

The `build_pkg_installer.sh` script automates:

- **Step 1:** Building release binary with Swift Package Manager
- **Step 2:** Creating proper macOS app bundle hierarchy
- **Step 3:** Generating pre/postinstall validation scripts
- **Step 4:** Creating component package with pkgbuild
- **Step 5:** Packaging as final distribution .pkg

---

## 🎓 For Enterprise/IT Teams

The .pkg installer is compatible with:
- **MDM Deployment** (Jamf, Kandji, etc.)
- **Apple Device Enrollment**
- **System Imaging Tools**
- **Automated Deployment Scripts**
- **Volume Licensing**

---

## 📞 Support

- 📖 See [BUILD.md](BUILD.md) for build instructions
- 📖 See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture details
- 📖 See [INSTALL.md](INSTALL.md) for comprehensive installation guide

---

**Happy securing! 🛡️**
