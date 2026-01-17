import Foundation

class SecurityCheckManager: ObservableObject {
    @Published var checks: [SecurityCheck] = []
    @Published var isRunning: Bool = false
    @Published var lastReport: SecurityReport?
    
    private let executor = SystemCommandExecutor.shared
    private var checkQueue = DispatchQueue(label: "com.security-checker.queue", attributes: .concurrent)
    
    init() {
        initializeChecks()
    }
    
    private func initializeChecks() {
        // OS & Firmware Hardening
        let osChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "os_latest_version",
                name: "Latest macOS Version",
                category: .osHardening,
                description: "Ensures system is running the latest macOS version",
                status: .unknown,
                hint: "Running the latest macOS version ensures you have the latest security patches and bug fixes. Always keep your system up-to-date.",
                remediation: "Software Update → Check Now",
                severity: 5,
                enforceable: false,
                apis: ["system_profiler"]
            ),
            SecurityCheck(
                id: "auto_security_updates",
                name: "Automatic Security Updates",
                category: .osHardening,
                description: "Automatic security updates are enabled",
                status: .unknown,
                hint: "Automatic security updates allow Apple to patch security vulnerabilities immediately without requiring manual intervention. This is critical for maintaining security.",
                remediation: "System Settings → General → Software Update → Automatic Updates",
                severity: 5,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "firmware_password",
                name: "Firmware Password",
                category: .osHardening,
                description: "Firmware password is enabled (Intel Macs)",
                status: .unknown,
                hint: "Firmware passwords protect against unauthorized access to Recovery Mode and prevent unauthorized operating system installation on Intel Macs.",
                remediation: "Restart → Hold Cmd+R → Utilities → Firmware Password Utility",
                severity: 4,
                enforceable: false,
                apis: ["firmwarepasswd"]
            ),
            SecurityCheck(
                id: "secure_boot",
                name: "Secure Boot Enabled",
                category: .osHardening,
                description: "Secure Boot set to Full Security (Apple Silicon)",
                status: .unknown,
                hint: "Secure Boot verifies that only trusted software can run before the operating system loads, protecting your Mac against bootkits and firmware-level attacks.",
                remediation: "Restart → Hold Power Button → Startup Security Policy",
                severity: 4,
                enforceable: false,
                apis: ["system_profiler"]
            ),
            SecurityCheck(
                id: "sip_enabled",
                name: "System Integrity Protection",
                category: .osHardening,
                description: "System Integrity Protection (SIP) is enabled",
                status: .unknown,
                hint: "System Integrity Protection prevents even administrator-level processes from modifying critical system files. This is essential for OS security.",
                remediation: "Restart → Hold Cmd+R → Utilities → Terminal → csrutil enable",
                severity: 5,
                enforceable: false,
                apis: ["csrutil"]
            ),
            SecurityCheck(
                id: "signed_system_volume",
                name: "Signed System Volume Intact",
                category: .osHardening,
                description: "System volume is cryptographically signed",
                status: .unknown,
                hint: "Code signing ensures your system volume hasn't been tampered with or infected by malware. This cryptographic signature proves OS integrity.",
                remediation: "Restore macOS or contact Apple Support",
                severity: 5,
                enforceable: false,
                apis: ["system_profiler"]
            )
        ]
        
        // User Authentication & Access Control
        let authChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "password_required_immediately",
                name: "Password Required After Sleep",
                category: .userAuthentication,
                description: "Password required immediately after sleep/screen saver",
                status: .unknown,
                hint: "Requiring a password immediately after sleep prevents unauthorized access if your Mac is left unattended. Don't allow login delays that create security gaps.",
                remediation: "System Settings → Lock Screen → Require password immediately after sleep",
                severity: 4,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "strong_password_policy",
                name: "Strong Password Policy",
                category: .userAuthentication,
                description: "Strong password policy enforced",
                status: .unknown,
                hint: "Strong passwords with complexity requirements are critical for preventing brute-force and dictionary attacks on your user accounts.",
                remediation: "Use System Settings → Users & Groups policies",
                severity: 4,
                enforceable: true,
                apis: ["dscl"]
            ),
            SecurityCheck(
                id: "no_shared_admin",
                name: "No Shared Admin Accounts",
                category: .userAuthentication,
                description: "No shared administrator accounts",
                status: .unknown,
                hint: "Shared admin accounts make it impossible to audit who made what changes. Each user should have their own unique administrator account for accountability.",
                remediation: "System Settings → Users & Groups → Ensure each admin is unique",
                severity: 4,
                enforceable: true,
                apis: ["dscl"]
            ),
            SecurityCheck(
                id: "guest_account_disabled",
                name: "Guest Account Disabled",
                category: .userAuthentication,
                description: "Guest account is disabled",
                status: .unknown,
                hint: "Disabled guest accounts prevent unauthorized temporary access to your system by external users. This eliminates an unnecessary attack vector.",
                remediation: "System Settings → Users & Groups → Guest Account → Uncheck",
                severity: 3,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "touch_id_enabled",
                name: "Touch ID Enabled",
                category: .userAuthentication,
                description: "Touch ID is enabled (where available)",
                status: .unknown,
                hint: "Touch ID provides convenient yet cryptographically secure authentication without exposing passwords. Enable it for faster and safer login.",
                remediation: "System Settings → Touch ID & Passcode",
                severity: 2,
                enforceable: false,
                apis: ["LocalAuthentication"]
            )
        ]
        
        // Disk & Data Protection
        let diskChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "filevault_enabled",
                name: "FileVault Enabled",
                category: .diskProtection,
                description: "Full disk encryption via FileVault",
                status: .unknown,
                hint: "FileVault encrypts your entire drive, protecting data even if your Mac is physically stolen. This is critical for sensitive information.",
                remediation: "System Settings → Privacy & Security → FileVault → Turn On",
                severity: 5,
                enforceable: true,
                apis: ["fdesetup"]
            ),
            SecurityCheck(
                id: "recovery_key_escrowed",
                name: "Recovery Key Escrowed",
                category: .diskProtection,
                description: "FileVault recovery key escrowed with MDM",
                status: .unknown,
                hint: "Escrow ensures you can still recover your encrypted data if you forget your password. MDM escrow provides organizational recovery capability.",
                remediation: "Configure MDM to escrow FileVault keys",
                severity: 4,
                enforceable: true,
                apis: ["MDM"]
            ),
            SecurityCheck(
                id: "external_drives_encrypted",
                name: "External Drives Encrypted",
                category: .diskProtection,
                description: "External drives encrypted or access restricted",
                status: .unknown,
                hint: "External drives can be easily stolen or shared with others. Encryption protects sensitive data on removable media and prevents unauthorized access.",
                remediation: "Right-click external drive → Encrypt",
                severity: 3,
                enforceable: true,
                apis: ["diskutil"]
            )
        ]
        
        // Application Security & Execution Control
        let appChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "gatekeeper_enabled",
                name: "Gatekeeper Enabled",
                category: .applicationSecurity,
                description: "Gatekeeper is enabled",
                status: .unknown,
                hint: "Gatekeeper prevents execution of unsigned and unnotarized applications, blocking malware and other threats.",
                remediation: "System Settings → Privacy & Security → Allow apps downloaded from",
                severity: 4,
                enforceable: false,
                apis: ["spctl"]
            ),
            SecurityCheck(
                id: "notarized_apps_only",
                name: "Notarized Apps Only",
                category: .applicationSecurity,
                description: "Only notarized apps are allowed",
                status: .unknown,
                hint: "Notarized apps have been scanned by Apple for malware and security issues. Requiring notarization significantly reduces the risk of installing compromised software.",
                remediation: "Enable 'Require notarization' via MDM",
                severity: 4,
                enforceable: true,
                apis: ["spctl"]
            ),
            SecurityCheck(
                id: "xprotect_enabled",
                name: "XProtect Enabled",
                category: .applicationSecurity,
                description: "XProtect malware protection enabled",
                status: .unknown,
                hint: "XProtect is macOS's built-in malware scanning engine that automatically checks downloaded files and applications for known threats.",
                remediation: "XProtect cannot be disabled on modern macOS",
                severity: 4,
                enforceable: false,
                apis: ["system_profiler"]
            ),
            SecurityCheck(
                id: "mrt_enabled",
                name: "MRT Enabled",
                category: .applicationSecurity,
                description: "Malware Removal Tool enabled",
                status: .unknown,
                hint: "The Malware Removal Tool automatically scans and removes known malware if detected on your system, providing an additional layer of protection.",
                remediation: "MRT runs automatically; cannot be disabled",
                severity: 3,
                enforceable: false,
                apis: ["system_profiler"]
            )
        ]
        
        // Permissions & Privacy (TCC)
        let privacyChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "tcc_least_privilege",
                name: "Least Privilege TCC",
                category: .permissionsPrivacy,
                description: "Apps have minimum required permissions",
                status: .unknown,
                hint: "Least privilege means applications only have access to what they actually need to function. This reduces risk if an app becomes compromised.",
                remediation: "System Settings → Privacy & Security → Review app permissions",
                severity: 3,
                enforceable: true,
                apis: ["TCC"]
            ),
            SecurityCheck(
                id: "fda_monitored",
                name: "Full Disk Access Monitored",
                category: .permissionsPrivacy,
                description: "Full Disk Access permissions are monitored",
                status: .unknown,
                hint: "Full Disk Access is one of the most dangerous permissions as it gives apps complete access to all files. Only grant this to trusted applications.",
                remediation: "System Settings → Privacy & Security → Full Disk Access → Review apps",
                severity: 4,
                enforceable: true,
                apis: ["TCC"]
            ),
            SecurityCheck(
                id: "camera_mic_protected",
                name: "Camera & Microphone Protected",
                category: .permissionsPrivacy,
                description: "Camera and microphone access is restricted",
                status: .unknown,
                hint: "Restricting camera and microphone access prevents unauthorized surveillance. Regularly review which apps have these permissions.",
                remediation: "System Settings → Privacy & Security → Camera/Microphone",
                severity: 4,
                enforceable: true,
                apis: ["TCC"]
            )
        ]
        
        // Network Security
        let networkChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "firewall_enabled",
                name: "Firewall Enabled",
                category: .networkSecurity,
                description: "macOS firewall is enabled",
                status: .unknown,
                hint: "The macOS firewall blocks incoming connections from untrusted sources, protecting your system from network attacks.",
                remediation: "System Settings → Network → Firewall → Turn On Firewall",
                severity: 4,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "stealth_mode_enabled",
                name: "Stealth Mode Enabled",
                category: .networkSecurity,
                description: "Stealth mode enabled",
                status: .unknown,
                hint: "Stealth mode prevents your Mac from responding to ping requests and port scans, making it less visible to attackers on the network.",
                remediation: "System Settings → Network → Firewall Options → Enable Stealth Mode",
                severity: 3,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "bluetooth_restricted",
                name: "Bluetooth Restricted",
                category: .networkSecurity,
                description: "Bluetooth discoverability restricted",
                status: .unknown,
                hint: "Disabling Bluetooth discoverability prevents nearby attackers from discovering and attempting to pair with your device.",
                remediation: "System Settings → Bluetooth → Discoverable: Off",
                severity: 2,
                enforceable: true,
                apis: ["defaults"]
            ),
            SecurityCheck(
                id: "dns_secure",
                name: "DNS Security",
                category: .networkSecurity,
                description: "DNS uses DoH or filtered DNS",
                status: .unknown,
                hint: "DNS over HTTPS (DoH) and encrypted DNS prevent ISPs and eavesdroppers from seeing which websites you visit, protecting your privacy.",
                remediation: "System Settings → Network → DNS → Add secure DNS provider",
                severity: 3,
                enforceable: true,
                apis: ["scutil"]
            )
        ]
        
        // Malware & Threat Protection
        let threatChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "xprotect_signatures",
                name: "XProtect Signatures Updated",
                category: .malwareProtection,
                description: "Known malware signatures are current",
                status: .unknown,
                hint: "Up-to-date XProtect signatures ensure the latest known malware variants are detected and blocked by the system.",
                remediation: "Automatic updates via System Settings",
                severity: 4,
                enforceable: false,
                apis: ["system_profiler"]
            ),
            SecurityCheck(
                id: "persistence_monitored",
                name: "Persistence Mechanisms Monitored",
                category: .malwareProtection,
                description: "LaunchAgents, LaunchDaemons, and cron jobs monitored",
                status: .unknown,
                hint: "Monitoring startup mechanisms helps detect malware attempting to survive system reboots and maintain persistent access.",
                remediation: "Use MDM for monitoring",
                severity: 3,
                enforceable: true,
                apis: ["EndpointSecurity"]
            )
        ]
        
        // System Integrity & Tamper Protection
        let integrityChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "system_volume_intact",
                name: "System Volume Integrity",
                category: .systemIntegrity,
                description: "System volume has not been modified",
                status: .unknown,
                hint: "An intact system volume ensures your operating system hasn't been modified by malware or attackers. This is fundamental to system security.",
                remediation: "Restore macOS if compromised",
                severity: 5,
                enforceable: false,
                apis: ["system_profiler"]
            ),
            SecurityCheck(
                id: "mdm_protected",
                name: "MDM Profile Protected",
                category: .systemIntegrity,
                description: "MDM profile removal is protected",
                status: .unknown,
                hint: "Protected MDM profiles prevent users from unenrolling from mobile device management, ensuring compliance policies remain enforced.",
                remediation: "Configure MDM with removal protection",
                severity: 4,
                enforceable: true,
                apis: ["MDM"]
            )
        ]
        
        // Logging & Auditing
        let loggingChecks: [SecurityCheck] = [
            SecurityCheck(
                id: "unified_logging_enabled",
                name: "Unified Logging Enabled",
                category: .loggingAuditing,
                description: "Unified logging captures security events",
                status: .unknown,
                hint: "Unified logging creates detailed audit trails of system events for forensic analysis, compliance investigations, and security incident response.",
                remediation: "Cannot be disabled; configure log retention",
                severity: 3,
                enforceable: false,
                apis: ["os_log"]
            ),
            SecurityCheck(
                id: "audit_enabled",
                name: "Audit Subsystem Enabled",
                category: .loggingAuditing,
                description: "Audit subsystem logs security-relevant events",
                status: .unknown,
                hint: "The audit subsystem records security-relevant events for compliance, incident investigation, and detection of suspicious activity on your system.",
                remediation: "Configure via audit_control",
                severity: 3,
                enforceable: true,
                apis: ["auditd"]
            )
        ]
        
        let allChecks = osChecks + authChecks + diskChecks + appChecks + privacyChecks + networkChecks + threatChecks + integrityChecks + loggingChecks
        self.checks = allChecks
    }
    
    func runAllChecks(completion: @escaping (SecurityReport?) -> Void) {
        isRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            var results: [SecurityCheckResult] = []
            
            // Run checks sequentially to avoid queue deadlocks
            for (index, check) in self.checks.enumerated() {
                let result = self.performCheck(check)
                results.append(result)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    if index < self.checks.count {
                        self.checks[index].status = result.check.status
                    }
                }
            }
            
            // Call completion on main thread
            DispatchQueue.main.async {
                let osVersion = self.getOSVersion()
                let score = self.calculateScore(from: results)
                let report = SecurityReport(
                    timestamp: Date(),
                    osVersion: osVersion,
                    checks: results,
                    overallScore: score
                )
                self.lastReport = report
                self.isRunning = false
                completion(report)
            }
        }
    }
    
    private func performCheck(_ check: SecurityCheck) -> SecurityCheckResult {
        var status: CheckStatus = .fail // Default to fail if we can't determine
        var details = ""
        var requiresElevation = false
        
        switch check.id {
        // OS & Firmware checks
        case "sip_enabled":
            let result = executor.shell("csrutil status 2>&1")
            status = result.output.contains("enabled") ? .pass : .fail
            details = result.output.isEmpty ? "Unable to check" : result.output
            
        case "filevault_enabled":
            let result = executor.shell("fdesetup status 2>&1")
            if result.exitCode == 0 {
                status = result.output.contains("On") ? .pass : .fail
            } else {
                status = .warning
            }
            details = result.output.isEmpty ? "Requires elevation" : result.output
            requiresElevation = true
            
        case "firewall_enabled":
            let result = executor.shell("defaults read /Library/Preferences/com.apple.alf globalstate 2>/dev/null || echo '0'")
            status = result.output.contains("1") ? .pass : .fail
            details = result.output.isEmpty ? "Not enabled" : result.output
            
        case "auto_security_updates":
            let result = executor.shell("defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null || echo '0'")
            status = result.output.contains("1") ? .pass : .fail
            details = result.output.isEmpty ? "Not enabled" : result.output
            
        case "password_required_immediately":
            let result = executor.shell("defaults read com.apple.screensaver askForPassword 2>/dev/null || echo '0'")
            status = result.output.contains("1") ? .pass : .fail
            details = result.output.isEmpty ? "Not set" : result.output
            
        case "guest_account_disabled":
            let result = executor.shell("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null || echo '1'")
            status = (result.output.contains("0") || result.output.contains("disabled")) ? .pass : .fail
            details = result.output.isEmpty ? "Guest account may be enabled" : result.output
            
        case "gatekeeper_enabled":
            let result = executor.shell("spctl --status 2>&1")
            status = result.output.contains("assessments enabled") ? .pass : .fail
            details = result.output.isEmpty ? "Unable to check" : result.output
            
        default:
            status = .warning
            details = "Check not yet fully implemented"
        }
        
        return SecurityCheckResult(
            check: SecurityCheck(
                id: check.id,
                name: check.name,
                category: check.category,
                description: check.description,
                status: status,
                hint: check.hint,
                remediation: check.remediation,
                severity: check.severity,
                enforceable: check.enforceable,
                apis: check.apis
            ),
            details: details,
            timestamp: Date(),
            requiresElevation: requiresElevation
        )
    }
    
    private func getOSVersion() -> String {
        let result = executor.shell("sw_vers -productVersion")
        return result.output
    }
    
    private func calculateScore(from results: [SecurityCheckResult]) -> Double {
        guard !results.isEmpty else { return 0.0 }
        
        var totalScore = 0.0
        var totalWeight = 0
        
        for result in results {
            let weight = result.check.severity
            let points = result.check.status == .pass ? weight : (result.check.status == .warning ? weight / 2 : 0)
            totalScore += Double(points)
            totalWeight += weight
        }
        
        return totalWeight > 0 ? (totalScore / Double(totalWeight)) * 100 : 0.0
    }
}
