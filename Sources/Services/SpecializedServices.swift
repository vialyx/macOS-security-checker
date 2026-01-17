import Foundation

class PrivacyService {
    static let shared = PrivacyService()
    private let executor = SystemCommandExecutor.shared
    
    func getTCCStatus() -> [String: String] {
        var tccStatus: [String: String] = [:]
        
        // Read Full Disk Access status
        let fda = executor.shell("sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db \"select service, client, allowed from access where service='kTCCServiceSystemPolicyFullDiskAccess'\" 2>/dev/null || echo 'N/A'")
        tccStatus["fullDiskAccess"] = fda.output
        
        // Check specific permissions
        let camera = executor.shell("defaults read ~/Library/Preferences/com.apple.TCC.plist Services 2>/dev/null | grep -c 'kTCCServiceCamera' || echo 0")
        tccStatus["camera"] = camera.output
        
        let microphone = executor.shell("defaults read ~/Library/Preferences/com.apple.TCC.plist Services 2>/dev/null | grep -c 'kTCCServiceMicrophone' || echo 0")
        tccStatus["microphone"] = microphone.output
        
        let screenRecording = executor.shell("defaults read ~/Library/Preferences/com.apple.TCC.plist Services 2>/dev/null | grep -c 'kTCCServiceScreenCapture' || echo 0")
        tccStatus["screenRecording"] = screenRecording.output
        
        return tccStatus
    }
    
    func getUnauthorizedAppsWithPermissions() -> [String] {
        let result = executor.shell("sqlite3 ~/Library/Application\\ Support/com.apple.TCC/TCC.db \"select service, client from access where allowed=1 and service='kTCCServiceFullDiskAccess'\" 2>/dev/null || echo ''")
        
        return result.output.split(separator: "\n").map(String.init)
    }
}

class FileVaultService {
    static let shared = FileVaultService()
    private let executor = SystemCommandExecutor.shared
    
    func getFileVaultStatus() -> FileVaultStatus {
        let result = executor.shell("fdesetup status 2>/dev/null || echo 'Permission Denied'")
        
        let isEnabled = result.output.contains("FileVault is On")
        let isEncrypting = result.output.contains("Encrypted") && !result.output.contains("Decrypted")
        
        var escrowStatus = "Unknown"
        if result.output.contains("Recovery Key escrowed") {
            escrowStatus = "Escrowed"
        } else if result.output.contains("Personal Recovery Key") {
            escrowStatus = "Personal Key"
        }
        
        return FileVaultStatus(
            isEnabled: isEnabled,
            isEncrypting: isEncrypting,
            recoveryKeyStatus: escrowStatus,
            fullOutput: result.output
        )
    }
}

struct FileVaultStatus {
    let isEnabled: Bool
    let isEncrypting: Bool
    let recoveryKeyStatus: String
    let fullOutput: String
}

class FirewallService {
    static let shared = FirewallService()
    private let executor = SystemCommandExecutor.shared
    
    func getFirewallStatus() -> FirewallStatus {
        let globalState = executor.shell("defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null")
        let stealthMode = executor.shell("defaults read /Library/Preferences/com.apple.alf stealthenabled 2>/dev/null")
        
        return FirewallStatus(
            isEnabled: globalState.output == "1",
            stealthModeEnabled: stealthMode.output == "1",
            loggingMode: getLoggingMode()
        )
    }
    
    private func getLoggingMode() -> String {
        let result = executor.shell("defaults read /Library/Preferences/com.apple.alf loggingenabled 2>/dev/null")
        switch result.output {
        case "0":
            return "Disabled"
        case "1":
            return "Enabled"
        case "2":
            return "Detailed"
        default:
            return "Unknown"
        }
    }
    
    func getBlockedApplications() -> [String] {
        let result = executor.shell("defaults read /Library/Preferences/com.apple.alf apps 2>/dev/null | grep 'path =' | cut -d '\"' -f 2")
        return result.output.split(separator: "\n").map(String.init)
    }
}

struct FirewallStatus {
    let isEnabled: Bool
    let stealthModeEnabled: Bool
    let loggingMode: String
}

class SystemIntegrityService {
    static let shared = SystemIntegrityService()
    private let executor = SystemCommandExecutor.shared
    
    func getSIPStatus() -> SIPStatus {
        let result = executor.shell("csrutil status 2>/dev/null")
        
        let isEnabled = result.output.contains("enabled")
        let configuration = parseSIPConfiguration(result.output)
        
        return SIPStatus(
            isEnabled: isEnabled,
            configuration: configuration,
            fullOutput: result.output
        )
    }
    
    private func parseSIPConfiguration(_ output: String) -> String {
        if output.contains("enabled") && !output.contains("Unknown") {
            return "Full Security"
        } else if output.contains("partially enabled") {
            return "Reduced Security"
        } else if output.contains("disabled") {
            return "Disabled"
        }
        return "Unknown"
    }
    
    func getSecureBootStatus() -> SecureBootStatus {
        let result = executor.shell("system_profiler SPSecureBootStatus 2>/dev/null")
        
        return SecureBootStatus(
            isEnabled: result.output.contains("Full Security") || result.output.contains("full"),
            mode: result.output.contains("Full Security") ? "Full" : "Unknown",
            fullOutput: result.output
        )
    }
}

struct SIPStatus {
    let isEnabled: Bool
    let configuration: String
    let fullOutput: String
}

struct SecureBootStatus {
    let isEnabled: Bool
    let mode: String
    let fullOutput: String
}

class MalwareService {
    static let shared = MalwareService()
    private let executor = SystemCommandExecutor.shared
    
    func getXProtectStatus() -> MalwareStatus {
        // XProtect status is available via system_profiler on some macOS versions
        _ = executor.shell("system_profiler SPSoftwareDataType | grep -A 5 'Antivirus'")
        
        return MalwareStatus(
            xprotectEnabled: true, // XProtect cannot be disabled on modern macOS
            mrtAvailable: checkMRTAvailability(),
            lastDefinitionUpdate: getLastDefinitionUpdate()
        )
    }
    
    private func checkMRTAvailability() -> Bool {
        let result = executor.shell("ls /System/Library/CoreServices/MalwareRemovalTool.app 2>/dev/null")
        return result.output.contains(".app")
    }
    
    private func getLastDefinitionUpdate() -> Date? {
        let result = executor.shell("stat -f %Sm /var/db/XProtect.meta.plist 2>/dev/null")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d HH:mm:ss yyyy"
        return dateFormatter.date(from: result.output)
    }
}

struct MalwareStatus {
    let xprotectEnabled: Bool
    let mrtAvailable: Bool
    let lastDefinitionUpdate: Date?
}

class NetworkService {
    static let shared = NetworkService()
    private let executor = SystemCommandExecutor.shared
    
    func getDNSConfiguration() -> DNSStatus {
        let dnsServers = executor.shell("scutil -d -v <<< 'show State:/Network/Global/DNS' 2>/dev/null | grep 'ServerAddresses'")
        
        return DNSStatus(
            servers: parseDNSServers(dnsServers.output),
            isSecure: isSecureDNS(dnsServers.output)
        )
    }
    
    private func parseDNSServers(_ output: String) -> [String] {
        return output.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
    }
    
    private func isSecureDNS(_ servers: String) -> Bool {
        // Check for known secure DNS providers (Cloudflare, Quad9, etc)
        let secureProviders = ["1.1.1.1", "9.9.9.9", "208.67.222.222"]
        return secureProviders.contains(where: { servers.contains($0) })
    }
}

struct DNSStatus {
    let servers: [String]
    let isSecure: Bool
}
