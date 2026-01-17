#!/bin/bash

#  build_pkg_installer.sh
#  Builds a macOS .pkg installer for Security Checker
#  Usage: ./build_pkg_installer.sh

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/.build/release"
APP_NAME="macOS-security-checker"
EXECUTABLE="${BUILD_DIR}/${APP_NAME}"
VERSION="1.0.0"
IDENTIFIER="com.maxim.security-checker"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔨 Building macOS Security Checker Installer${NC}"
echo ""

# Step 1: Build the executable
echo -e "${YELLOW}Step 1: Building executable...${NC}"
if [ ! -f "${EXECUTABLE}" ]; then
    echo "Building release binary..."
    cd "${PROJECT_DIR}"
    swift build -c release
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi
fi

if [ ! -f "${EXECUTABLE}" ]; then
    echo -e "${RED}✗ Executable not found at ${EXECUTABLE}${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Executable built${NC}"
echo ""

# Step 2: Create temporary directory structure
echo -e "${YELLOW}Step 2: Creating package structure...${NC}"

TEMP_DIR=$(mktemp -d)
PAYLOAD_DIR="${TEMP_DIR}/payload"
SCRIPTS_DIR="${TEMP_DIR}/scripts"

# Create directories
mkdir -p "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/MacOS"
mkdir -p "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/Resources"
mkdir -p "${PAYLOAD_DIR}/Library/LaunchAgents"
mkdir -p "${SCRIPTS_DIR}"

# Copy executable
cp "${EXECUTABLE}" "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"
chmod +x "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Copy Info.plist
if [ -f "${PROJECT_DIR}/Info.plist" ]; then
    cp "${PROJECT_DIR}/Info.plist" "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/Info.plist"
else
    # Generate Info.plist if not found
    cat > "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>MacOS Security Checker</string>
    <key>CFBundleName</key>
    <string>MacOS Security Checker</string>
    <key>CFBundleIdentifier</key>
    <string>com.security.macos-security-checker</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>macOS-security-checker</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSMinimumOSVersion</key>
    <string>12.0</string>
</dict>
</plist>
PLIST
fi

# Create Info.plist
cat > "${PAYLOAD_DIR}/Applications/${APP_NAME}.app/Contents/Info.plist" << 'EOF'
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
	<string>1.0.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>12.0</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2025 Maxim Vialykh. All rights reserved.</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSRequiresIPhoneOS</key>
	<false/>
</dict>
</plist>
EOF

echo -e "${GREEN}✓ Package structure created${NC}"
echo ""

# Step 3: Create installation scripts
echo -e "${YELLOW}Step 3: Creating installation scripts...${NC}"

# Preinstall script
cat > "${SCRIPTS_DIR}/preinstall" << 'SCRIPT'
#!/bin/bash
# Pre-installation checks

echo "Checking system requirements..."

# Check macOS version
OS_VERSION=$(sw_vers -productVersion)
REQUIRED_VERSION="12.0"

# Simple version comparison
if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$OS_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
    echo "Error: macOS $REQUIRED_VERSION or later is required"
    exit 1
fi

echo "✓ System requirements met"
exit 0
SCRIPT

chmod +x "${SCRIPTS_DIR}/preinstall"

# Postinstall script
cat > "${SCRIPTS_DIR}/postinstall" << 'SCRIPT'
#!/bin/bash
# Post-installation setup

APP_PATH="/Applications/macOS-security-checker.app"
CONFIG_DIR="${HOME}/.security-checker"

echo "Setting up macOS Security Checker..."

# Create configuration directory
mkdir -p "${CONFIG_DIR}"

# Create default configuration if it doesn't exist
if [ ! -f "${CONFIG_DIR}/config.json" ]; then
    cat > "${CONFIG_DIR}/config.json" << 'CONFIG'
{
  "scanInterval": 3600,
  "alertOnChanges": true,
  "remediationLevel": "guided",
  "complianceBenchmark": "CIS",
  "mdmEnabled": false,
  "autoRemediationEnabled": false,
  "exportFormat": "json"
}
CONFIG
fi

# Fix permissions
chmod +x "${APP_PATH}/Contents/MacOS/macOS-security-checker"

echo "✓ Installation complete"
echo "✓ Launch from Applications folder or Spotlight"
echo ""
echo "Quick start:"
echo "  /Applications/macOS-security-checker.app/Contents/MacOS/macOS-security-checker"
echo ""

exit 0
SCRIPT

chmod +x "${SCRIPTS_DIR}/postinstall"

echo -e "${GREEN}✓ Installation scripts created${NC}"
echo ""

# Step 4: Create component plist
echo -e "${YELLOW}Step 4: Creating component package...${NC}"

pkgbuild \
    --root "${PAYLOAD_DIR}" \
    --scripts "${SCRIPTS_DIR}" \
    --identifier "${IDENTIFIER}.pkg" \
    --version "${VERSION}" \
    --install-location "/" \
    "${TEMP_DIR}/${APP_NAME}-${VERSION}.pkg" 2>/dev/null

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Component package creation failed${NC}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

echo -e "${GREEN}✓ Component package created${NC}"
echo ""

# Step 5: Create final installer
echo -e "${YELLOW}Step 5: Creating final installer package...${NC}"

OUTPUT_DIR="${PROJECT_DIR}/dist"
mkdir -p "${OUTPUT_DIR}"

OUTPUT_PKG="${OUTPUT_DIR}/macOS-security-checker-${VERSION}.pkg"

# Use simple copy since productbuild requires distribution file
cp "${TEMP_DIR}/${APP_NAME}-${VERSION}.pkg" "${OUTPUT_PKG}"

if [ ! -f "${OUTPUT_PKG}" ]; then
    echo -e "${RED}✗ Failed to create installer package${NC}"
    rm -rf "${TEMP_DIR}"
    exit 1
fi

# Cleanup
rm -rf "${TEMP_DIR}"

echo -e "${GREEN}✓ Installer package created${NC}"
echo ""

# Final message
echo -e "${GREEN}✅ macOS Security Checker ${VERSION} installer ready!${NC}"
echo ""
echo "📦 Installer location:"
echo "   ${OUTPUT_PKG}"
echo ""
echo "📥 To install:"
echo "   open '${OUTPUT_PKG}'"
echo ""
echo "Or double-click the .pkg file"
echo ""
