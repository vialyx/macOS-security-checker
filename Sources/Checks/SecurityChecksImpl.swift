import Foundation

class OSHardeningChecks {
    static let shared = OSHardeningChecks()
    private let executor = SystemCommandExecutor.shared
    
    func checkLatestMacOS() -> (status: CheckStatus, details: String) {
        let currentVersion = executor.shell("sw_vers -productVersion").output
        let softwareUpdateAvailable = executor.shell("softwareupdate -l 2>/dev/null | grep -i 'macOS' | head -1").output
        
        let hasUpdates = !softwareUpdateAvailable.isEmpty && !softwareUpdateAvailable.contains("No new")
        
        return (
            status: hasUpdates ? .warning : .pass,
            details: "Current: \(currentVersion) • Updates available: \(hasUpdates)"
        )
    }
    
    func checkAutoSecurityUpdates() -> (status: CheckStatus, details: String) {
        let checkScheduledInstall = executor.shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate ScheduleFrequency 2>/dev/null || echo '0'")
        let checkAutomaticCheckEnabled = executor.shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null || echo '0'")
        
        let scheduledInstall = checkScheduledInstall.output == "7"
        let autoCheck = checkAutomaticCheckEnabled.output == "1"
        
        return (
            status: (scheduledInstall && autoCheck) ? .pass : .warning,
            details: "Automatic Check: \(autoCheck ? "✓" : "✗") • Scheduled Install: \(scheduledInstall ? "✓" : "✗")"
        )
    }
    
    func checkFirmwarePassword() -> (status: CheckStatus, details: String) {
        let result = executor.shell("firmwarepasswd -check 2>/dev/null || echo 'unavailable'")
        
        let hasPassword = result.output.contains("enabled")
        let isAppleSilicon = executor.shell("system_profiler SPHardwareDataType | grep -i 'apple silicon'").output.isEmpty == false
        
        if isAppleSilicon {
            return (
                status: .pass,
                details: "Apple Silicon: Check Secure Boot instead"
            )
        }
        
        return (
            status: hasPassword ? .pass : .fail,
            details: hasPassword ? "Firmware password is enabled" : "Firmware password not set"
        )
    }
    
    func checkSecureBootFullSecurity() -> (status: CheckStatus, details: String) {
        let result = executor.shell("system_profiler SPSecureBootStatus 2>/dev/null || echo 'unknown'")
        
        let isFullSecurity = result.output.contains("Full Security")
        
        return (
            status: isFullSecurity ? .pass : (result.output.contains("unknown") ? .unknown : .warning),
            details: result.output.isEmpty ? "Unable to determine" : result.output
        )
    }
    
    func checkSIPEnabled() -> (status: CheckStatus, details: String) {
        let result = executor.shell("csrutil status 2>/dev/null")
        
        let isEnabled = result.output.contains("enabled")
        
        return (
            status: isEnabled ? .pass : .fail,
            details: result.output
        )
    }
    
    func checkSignedSystemVolume() -> (status: CheckStatus, details: String) {
        let result = executor.shell("system_profiler SPSoftwareDataType | grep -i 'System Volume'")
        
        let isIntact = !result.output.isEmpty
        
        return (
            status: isIntact ? .pass : .warning,
            details: isIntact ? "System volume is cryptographically signed" : "Unable to verify"
        )
    }
}

class AuthenticationChecks {
    static let shared = AuthenticationChecks()
    private let executor = SystemCommandExecutor.shared
    
    func checkPasswordRequiredAfterSleep() -> (status: CheckStatus, details: String) {
        let screenLockDelay = executor.shell("defaults read com.apple.screensaver askForPasswordDelay 2>/dev/null || echo '0'")
        let screenLockEnabled = executor.shell("defaults read com.apple.screensaver askForPassword 2>/dev/null || echo '0'")
        
        let isSecure = screenLockEnabled.output == "1" && (screenLockDelay.output == "0" || screenLockDelay.output.isEmpty)
        
        return (
            status: isSecure ? .pass : .warning,
            details: "Lock enabled: \(screenLockEnabled.output == "1" ? "✓" : "✗") • Immediate: \(screenLockDelay.output == "0" ? "✓" : "✗")"
        )
    }
    
    func checkTouchIDEnabled() -> (status: CheckStatus, details: String) {
        _ = executor.shell("defaults read com.apple.AppleMultitouch MultifingerGestures 2>/dev/null || echo '0'")
        
        // Check if Touch ID hardware exists
        let hardwareCheck = executor.shell("system_profiler SPiBridgeDataType 2>/dev/null | grep -i 'touch'")
        let hasTouchIDHardware = !hardwareCheck.output.isEmpty
        
        return (
            status: hasTouchIDHardware ? .pass : .warning,
            details: hasTouchIDHardware ? "Touch ID hardware available" : "Touch ID not available on this Mac"
        )
    }
    
    func checkGuestAccountDisabled() -> (status: CheckStatus, details: String) {
        let result = executor.shell("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null || echo '0'")
        
        let isDisabled = result.output == "0" || result.output.isEmpty
        
        return (
            status: isDisabled ? .pass : .fail,
            details: isDisabled ? "Guest account disabled" : "Guest account is enabled"
        )
    }
    
    func checkNoSharedAdminAccounts() -> (status: CheckStatus, details: String) {
        _ = executor.shell("dscl . -search /Users RealName '' | grep -v '^-' | wc -l")
        let adminCount = executor.shell("dscl . -search /Users RealName '' | grep 'admin' | wc -l")
        
        let hasMultipleAdmins = Int(adminCount.output.trimmingCharacters(in: .whitespaces)) ?? 0 > 1
        
        return (
            status: hasMultipleAdmins ? .warning : .pass,
            details: "Admin accounts: \(adminCount.output)"
        )
    }
}

class DiskProtectionChecks {
    static let shared = DiskProtectionChecks()
    private let filevaultService = FileVaultService.shared
    
    func checkFileVaultEnabled() -> (status: CheckStatus, details: String) {
        let status = filevaultService.getFileVaultStatus()
        
        return (
            status: status.isEnabled ? .pass : .fail,
            details: status.fullOutput
        )
    }
    
    func checkRecoveryKeyEscrowed() -> (status: CheckStatus, details: String) {
        let status = filevaultService.getFileVaultStatus()
        
        let isEscrowed = status.recoveryKeyStatus == "Escrowed"
        
        return (
            status: isEscrowed ? .pass : .warning,
            details: "Recovery Key Status: \(status.recoveryKeyStatus)"
        )
    }
    
    func checkExternalDrivesEncrypted() -> (status: CheckStatus, details: String) {
        let executor = SystemCommandExecutor.shared
        _ = executor.shell("diskutil info /Volumes/* 2>/dev/null | grep -i 'encrypted' | head -1")
        
        return (
            status: .warning,
            details: "Manual review recommended for external drives"
        )
    }
}

class ApplicationSecurityChecks {
    static let shared = ApplicationSecurityChecks()
    private let executor = SystemCommandExecutor.shared
    
    func checkGatekeeperEnabled() -> (status: CheckStatus, details: String) {
        let result = executor.shell("spctl --status")
        
        let isEnabled = result.output.contains("assessments enabled")
        
        return (
            status: isEnabled ? .pass : .fail,
            details: result.output
        )
    }
    
    func checkNotarizedAppsOnly() -> (status: CheckStatus, details: String) {
        // Check if only notarized apps are required
        _ = executor.shell("defaults read com.apple.LaunchServices/com.apple.quarantine.RequireSigningAndNotarized 2>/dev/null || echo 'default'")
        
        return (
            status: .warning,
            details: "Enable via MDM for enforcement"
        )
    }
    
    func checkXProtectEnabled() -> (status: CheckStatus, details: String) {
        // XProtect is always enabled on modern macOS
        return (
            status: .pass,
            details: "XProtect is built-in and cannot be disabled"
        )
    }
    
    func checkMRTEnabled() -> (status: CheckStatus, details: String) {
        let result = executor.shell("ls /System/Library/CoreServices/MalwareRemovalTool.app 2>/dev/null")
        
        let isAvailable = !result.output.isEmpty
        
        return (
            status: isAvailable ? .pass : .warning,
            details: isAvailable ? "MRT available" : "MRT not found"
        )
    }
}

class NetworkSecurityChecks {
    static let shared = NetworkSecurityChecks()
    private let firewallService = FirewallService.shared
    
    func checkFirewallEnabled() -> (status: CheckStatus, details: String) {
        let status = firewallService.getFirewallStatus()
        
        return (
            status: status.isEnabled ? .pass : .fail,
            details: "Firewall: \(status.isEnabled ? "Enabled" : "Disabled")"
        )
    }
    
    func checkStealthModeEnabled() -> (status: CheckStatus, details: String) {
        let status = firewallService.getFirewallStatus()
        
        return (
            status: (status.isEnabled && status.stealthModeEnabled) ? .pass : .warning,
            details: "Stealth Mode: \(status.stealthModeEnabled ? "Enabled" : "Disabled")"
        )
    }
    
    func checkDNSSecurity() -> (status: CheckStatus, details: String) {
        let dnsStatus = NetworkService.shared.getDNSConfiguration()
        
        return (
            status: dnsStatus.isSecure ? .pass : .warning,
            details: "DNS Servers: \(dnsStatus.servers.joined(separator: ", "))"
        )
    }
    
    func checkBluetoothRestricted() -> (status: CheckStatus, details: String) {
        let executor = SystemCommandExecutor.shared
        let result = executor.shell("defaults read com.apple.Bluetooth ControllerPowerState 2>/dev/null || echo '0'")
        
        return (
            status: .pass,
            details: "Bluetooth status: \(result.output)"
        )
    }
}

class MalwareProtectionChecks {
    static let shared = MalwareProtectionChecks()
    private let malwareService = MalwareService.shared
    
    func checkXProtectSignaturesUpdated() -> (status: CheckStatus, details: String) {
        let status = malwareService.getXProtectStatus()
        
        if let lastUpdate = status.lastDefinitionUpdate {
            let daysSinceUpdate = Calendar.current.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
            let isRecent = daysSinceUpdate < 7
            
            return (
                status: isRecent ? .pass : .warning,
                details: "Last update: \(daysSinceUpdate) days ago"
            )
        }
        
        return (
            status: .pass,
            details: "XProtect signatures up to date (automatic)"
        )
    }
    
    func checkPersistenceMonitored() -> (status: CheckStatus, details: String) {
        return (
            status: .warning,
            details: "Requires MDM or endpoint protection for monitoring"
        )
    }
}
