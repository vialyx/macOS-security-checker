# Build Instructions

## Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later (includes Swift 5.9+)
- Command Line Tools: `xcode-select --install`

## Building from Source

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/macOS-security-checker.git
cd macOS-security-checker
```

### 2. Build with Swift Package Manager

```bash
# Debug build
swift build

# Release build (optimized)
swift build -c release

# Verbose output
swift build -v
```

### 3. Run Tests
```bash
swift test -v
```

### 4. Run the Application

```bash
# From command line
./.build/release/macOS-security-checker

# Or directly with swift
swift run macOS-security-checker
```

## Building as a Standalone App

To build as a macOS menu bar app, you need to wrap it in an app bundle:

```bash
# Create app bundle
mkdir -p macOS-security-checker.app/Contents/MacOS
mkdir -p macOS-security-checker.app/Contents/Resources

# Copy executable
cp .build/release/macOS-security-checker macOS-security-checker.app/Contents/MacOS/

# Create Info.plist
cat > macOS-security-checker.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>macOS-security-checker</string>
    <key>CFBundleIdentifier</key>
    <string>com.maxim.security-checker</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>macOS Security Checker</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSRequiresIPhoneOS</key>
    <false/>
    <key>UIDeviceFamily</key>
    <array>
        <integer>1</integer>
    </array>
</dict>
</plist>
EOF

# Launch the app
open macOS-security-checker.app
```

## Using Xcode

### Generate Xcode Project

```bash
# Swift Package Manager can generate Xcode projects
swift package generate-xcodeproj
open macOS-security-checker.xcodeproj
```

Then:
1. Select the scheme
2. Choose Product → Build (Cmd+B)
3. Run with Product → Run (Cmd+R)

## Installation

### Option 1: Copy to Applications
```bash
cp -r macOS-security-checker.app /Applications/
```

### Option 2: Install via Homebrew (after publishing)
```bash
brew install maxim/tools/macOS-security-checker
```

### Option 3: Launch at Login
```bash
mkdir -p ~/Library/LaunchAgents
cp com.maxim.security-checker.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.maxim.security-checker.plist
```

## Troubleshooting Build Issues

### "Cannot find module"
```bash
# Clean build artifacts
rm -rf .build
swift build
```

### Permission denied errors
```bash
# Ensure build directory is writable
chmod -R u+w .build
```

### XCode issues
```bash
# Reset Xcode
xcode-select --reset
xcode-select --install
```

## Granting Permissions

The app requires Full Disk Access to function properly:

1. **Grant Full Disk Access:**
   - System Settings → Privacy & Security → Full Disk Access
   - Add the app to the list

2. **Grant Elevated Privileges:**
   - The app will prompt for sudo when needed
   - Some checks require root access

## Development Workflow

### Building during development
```bash
# Watch mode (rebuild on file changes)
swift build -v --watch
```

### Code formatting
```bash
# Install swift-format
brew install swift-format

# Format all files
swift-format -i -r Sources/
```

### Linting
```bash
# Install swiftlint
brew install swiftlint

# Run linter
swiftlint
```

## Performance Optimization

Build release version with optimizations:
```bash
swift build -c release -Xswiftc -O -Xswiftc -whole-module-optimization
```

## Distribution

### Creating a DMG

```bash
# Create temporary directory
mkdir -p tmp/macOS\ Security\ Checker

# Copy app
cp -r macOS-security-checker.app tmp/macOS\ Security\ Checker/

# Create DMG
hdiutil create -volname "macOS Security Checker" \
  -srcfolder tmp \
  -ov -format UDZO \
  macOS-security-checker.dmg

# Clean up
rm -rf tmp
```

### Notarization for Distribution

```bash
# Sign the app
codesign -s "Developer ID Application" macOS-security-checker.app

# Submit for notarization
xcrun altool --notarize-app -f macOS-security-checker.dmg \
  -t osx -u your@email.com -p your-app-password

# Check status
xcrun altool --notarization-info <RequestID> \
  -u your@email.com -p your-app-password

# Staple notarization
xcrun stapler staple macOS-security-checker.dmg
```

## CI/CD

GitHub Actions workflow automatically:
- Builds on every push to main/develop
- Runs tests
- Creates release artifacts

See `.github/workflows/build.yml` for details.
