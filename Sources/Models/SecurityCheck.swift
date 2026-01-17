import Foundation

enum CheckStatus: String, Codable {
    case pass = "pass"
    case warning = "warning"
    case fail = "fail"
    case unknown = "unknown"
    
    var displayName: String {
        switch self {
        case .pass:
            return "✅ Secure"
        case .warning:
            return "⚠️ Warning"
        case .fail:
            return "❌ Failed"
        case .unknown:
            return "❓ Unknown"
        }
    }
    
    var color: String {
        switch self {
        case .pass:
            return "green"
        case .warning:
            return "orange"
        case .fail:
            return "red"
        case .unknown:
            return "gray"
        }
    }
}

enum SecurityCategory: String, CaseIterable, Codable {
    case osHardening = "OS & Firmware Hardening"
    case userAuthentication = "User Authentication & Access Control"
    case diskProtection = "Disk & Data Protection"
    case applicationSecurity = "Application Security & Execution"
    case permissionsPrivacy = "Permissions & Privacy (TCC)"
    case networkSecurity = "Network Security"
    case malwareProtection = "Malware & Threat Protection"
    case systemIntegrity = "System Integrity & Tamper Protection"
    case loggingAuditing = "Logging, Monitoring & Auditing"
    case compliance = "Compliance & Posture Assessment"
}

struct SecurityCheck: Identifiable, Codable {
    let id: String
    let name: String
    let category: SecurityCategory
    let description: String
    var status: CheckStatus
    let remediation: String?
    let severity: Int // 1-5, where 5 is critical
    let enforceable: Bool
    let apis: [String]
    
    mutating func updateStatus(_ newStatus: CheckStatus) {
        self.status = newStatus
    }
}

struct SecurityCheckResult: Codable {
    let check: SecurityCheck
    let details: String
    let timestamp: Date
    let requiresElevation: Bool
}

struct SecurityReport: Codable {
    let timestamp: Date
    let osVersion: String
    let checks: [SecurityCheckResult]
    let overallScore: Double
    
    var passedCount: Int {
        checks.filter { $0.check.status == .pass }.count
    }
    
    var failedCount: Int {
        checks.filter { $0.check.status == .fail }.count
    }
    
    var warningCount: Int {
        checks.filter { $0.check.status == .warning }.count
    }
    
    var totalCount: Int {
        checks.count
    }
}
