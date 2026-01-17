# Development Guide

## Quick Start

1. **Clone and build:**
   ```bash
   git clone <repo>
   cd macOS-security-checker
   swift build
   ```

2. **Run the app:**
   ```bash
   ./.build/release/macOS-security-checker
   ```

3. **Edit and test:**
   - Main logic: `Sources/Services/SecurityCheckManager.swift`
   - Individual checks: `Sources/Checks/SecurityChecksImpl.swift`
   - UI: `Sources/UI/App.swift`

## Architecture Overview

### Layer 1: Models (`Sources/Models/`)
- `SecurityCheck.swift` - Data structures for checks and reports
  - `CheckStatus` enum (pass, warning, fail, unknown)
  - `SecurityCategory` enum (11 categories)
  - `SecurityCheck` - Individual check definition
  - `SecurityReport` - Complete assessment result

### Layer 2: Services (`Sources/Services/`)

**Core Services:**
- `SystemCommandExecutor.swift` - Execute shell commands safely
- `SecurityCheckManager.swift` - Orchestrate all checks

**Specialized Services:**
- `PrivacyService` - TCC database access (permissions)
- `FileVaultService` - Disk encryption status
- `FirewallService` - Network firewall status
- `SystemIntegrityService` - SIP and Secure Boot
- `MalwareService` - XProtect and MRT status
- `NetworkService` - DNS and network configuration

**Infrastructure:**
- `ConfigurationManager.swift` - App preferences
- `ReportGenerator.swift` - Export to JSON/CSV/HTML

### Layer 3: Checks (`Sources/Checks/`)
- `SecurityChecksImpl.swift` - 50+ specific security checks
  - `OSHardeningChecks`
  - `AuthenticationChecks`
  - `DiskProtectionChecks`
  - `ApplicationSecurityChecks`
  - `NetworkSecurityChecks`
  - `MalwareProtectionChecks`

### Layer 4: UI (`Sources/UI/`)
- `App.swift` - Menu bar app and main views
- `DetailViews.swift` - Detail panels and settings

## Adding a New Security Check

### Step 1: Define the Check

Edit `SecurityCheckManager.swift` in the `initializeChecks()` method:

```swift
SecurityCheck(
    id: "unique_check_id",
    name: "Display Name",
    category: .categoryName,
    description: "What this checks for",
    status: .unknown,
    remediation: "Steps to fix if failed",
    severity: 4,  // 1-5, higher = more critical
    enforceable: true,  // Can MDM enforce this?
    apis: ["api_name", "command_name"]
)
```

### Step 2: Implement Check Logic

In the `performCheck()` method:

```swift
case "unique_check_id":
    let result = executor.shell("system_command")
    let isSecure = result.output.contains("expected")
    status = isSecure ? .pass : .fail
    details = result.output
```

### Step 3: Test

```bash
swift build
./.build/release/macOS-security-checker
```

## System Command Execution

The `SystemCommandExecutor` safely runs shell commands:

```swift
// Simple command
let result = executor.shell("command")
print(result.output)   // Command output
print(result.error)    // Error if any
print(result.exitCode) // Exit code (0 = success)

// With arguments
let result = executor.execute("/usr/bin/somecmd", arguments: ["arg1", "arg2"])
```

## Working with Files and Databases

### Reading Files
```swift
let filePath = "~/.config/file.plist"
let expanded = NSHomeDirectoryForUser(NSUserName()) + "/.config/file.plist"
let content = try String(contentsOfFile: expanded, encoding: .utf8)
```

### Accessing TCC Database (Permissions)
```swift
let privacyService = PrivacyService.shared
let tccStatus = privacyService.getTCCStatus()
let unauthorizedApps = privacyService.getUnauthorizedAppsWithPermissions()
```

### Reading System Information
```swift
let executor = SystemCommandExecutor.shared

// Get macOS version
let version = executor.shell("sw_vers -productVersion").output

// Get hardware info
let hardware = executor.shell("system_profiler SPHardwareDataType").output

// Check if Apple Silicon
let isAppleSilicon = executor.shell("uname -m").output.contains("arm")
```

## Working with Preferences (defaults)

```swift
// Read preference
let value = executor.shell("defaults read com.apple.domain key").output

// Write preference (requires sudo for system preferences)
let result = executor.shell("defaults write ~/Library/Preferences/domain.plist key value")
```

## Managing Elevated Privileges

Some checks require sudo:

```swift
func performSensitiveCheck() -> (status: CheckStatus, details: String) {
    let result = executor.shell("sudo fdesetup status")
    
    // Check if elevation was needed
    if result.error.contains("not authorized") {
        return (.fail, "Elevated privileges required")
    }
    
    return (.pass, result.output)
}
```

## Error Handling

```swift
do {
    let report = try ReportGenerator.shared.saveReport(report, format: .json)
    print("Saved to: \(report.path)")
} catch ReportError.encodingFailed {
    print("Failed to encode report")
} catch {
    print("Unknown error: \(error)")
}
```

## Testing Checks

### Manual Testing
```bash
# Run a specific check
swift run macOS-security-checker

# View detailed output
./.build/release/macOS-security-checker | grep "Failed"
```

### Unit Tests
Create `Tests/SecurityCheckerTests/` directory:

```swift
import XCTest
@testable import SecurityChecker

class OSHardeningTests: XCTestCase {
    func testSIPEnabled() {
        let check = OSHardeningChecks()
        let result = check.checkSIPEnabled()
        XCTAssertNotEqual(result.status, .unknown)
    }
}
```

Run tests:
```bash
swift test -v
```

## UI Components

### Menu Bar Label
Shows security status with color coding:
- Green shield (✓) = 80%+ passed
- Orange warning (⚠) = 50-79% passed
- Red slash (✕) = <50% passed

### Menu Bar View
Displays:
- Overall security score
- Summary cards (passed/warning/failed counts)
- Expandable category list
- Quick actions

### Detail View
Shows individual check details with:
- Status and severity
- Description
- Remediation steps
- API information
- Enforcement capability

## Performance Optimization

### Parallel Execution
Checks run concurrently via DispatchQueue:

```swift
let group = DispatchGroup()
for check in checks {
    group.enter()
    checkQueue.async {
        // Perform check
        group.leave()
    }
}
group.notify(queue: .main) {
    // All done
}
```

### Caching
Results are cached with timestamp:

```swift
@Published var lastReport: SecurityReport?
```

### Scan Intervals
Configurable via preferences:
```swift
let config = AppConfig.load()
let scanInterval = config.scanInterval  // seconds
```

## API Reference

### Check Status Values

```swift
enum CheckStatus {
    case pass       // ✅ All requirements met
    case warning    // ⚠️ Attention needed but not critical
    case fail       // ❌ Security issue found
    case unknown    // ❓ Cannot determine status
}
```

### Severity Levels

```
1 - Low: Minor security improvement
2 - Medium: Recommended configuration
3 - High: Important security measure
4 - Critical: Essential protection
5 - Severe: Must be enabled
```

### Security Categories

1. OS & Firmware Hardening
2. User Authentication & Access Control
3. Disk & Data Protection
4. Application Security & Execution
5. Permissions & Privacy (TCC)
6. Network Security
7. Malware & Threat Protection
8. System Integrity & Tamper Protection
9. Logging, Monitoring & Auditing
10. Compliance & Posture Assessment

## Compliance Benchmarks

Supported frameworks:
- **CIS macOS Benchmark** - Comprehensive controls
- **NIST 800-53** - Federal information security
- **NIST 800-171** - Controlled unclassified information
- **SOC 2 Type II** - Service organization controls
- **Zero Trust Model** - Continuous verification

## Debugging

### Enable Verbose Output
```bash
swift build -v
swift test -v
```

### Check System Requirements
```bash
# Verify Swift version
swift --version

# Check macOS version
sw_vers

# Verify command availability
which csrutil
which fdesetup
which spctl
```

### Common Issues

**"Permission Denied"**
- App needs Full Disk Access or sudo elevation
- Grant in System Settings → Privacy & Security

**"Command not found"**
- Command-line tools not installed
- Run: `xcode-select --install`

**"Unknown status" for all checks**
- macOS version too old (requires 12+)
- Check that system_profiler is available

## Contributing New Checks

1. **Identify the security measure**
   - Research macOS documentation
   - Find relevant API or command

2. **Create check definition**
   - Add to appropriate category in `SecurityCheckManager`
   - Set appropriate severity

3. **Implement check logic**
   - Add case in `performCheck()` method
   - Test with current macOS version

4. **Document the fix**
   - Clear remediation steps
   - Links to relevant documentation

5. **Test thoroughly**
   - Run on macOS 12+
   - Verify with both secure and insecure configurations

## Release Checklist

- [ ] Update version in Package.swift
- [ ] Update README.md with new checks
- [ ] Run full test suite: `swift test`
- [ ] Build release: `swift build -c release`
- [ ] Create DMG distribution
- [ ] Sign and notarize
- [ ] Tag release in git
- [ ] Create GitHub release notes

## Resources

- [Apple Security Documentation](https://developer.apple.com/security/)
- [CIS macOS Benchmark](https://www.cisecurity.org/benchmark/macos/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [macOS System Programming Guide](https://developer.apple.com/documentation/)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

## Support & Questions

- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Email: security@example.com
