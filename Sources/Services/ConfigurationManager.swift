import Foundation

struct AppConfig: Codable {
    var scanInterval: Int = 3600 // seconds
    var alertOnChanges: Bool = true
    var remediationLevel: RemediationLevel = .guided
    var complianceBenchmark: ComplianceBenchmark = .cis
    var mdmEnabled: Bool = false
    var logLevel: LogLevel = .info
    var autoRemediationEnabled: Bool = false
    var exportFormat: ExportFormat = .json
    
    static let configPath = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent(".security-checker")
        .appendingPathComponent("config.json")
    
    static func load() -> AppConfig {
        do {
            let data = try Data(contentsOf: configPath)
            let decoder = JSONDecoder()
            return try decoder.decode(AppConfig.self, from: data)
        } catch {
            print("Using default configuration: \(error)")
            return AppConfig()
        }
    }
    
    func save() throws {
        let directory = Self.configPath.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        try data.write(to: Self.configPath)
    }
}

enum RemediationLevel: String, Codable {
    case manual = "manual"
    case guided = "guided"
    case automatic = "automatic"
}

enum ComplianceBenchmark: String, Codable {
    case cis = "CIS"
    case nist80053 = "NIST_800-53"
    case nist80171 = "NIST_800-171"
    case soc2 = "SOC2"
    case zeroTrust = "Zero Trust"
}

enum LogLevel: String, Codable {
    case debug
    case info
    case warning
    case error
}

enum ExportFormat: String, Codable {
    case json
    case csv
    case pdf
}

class ConfigurationManager {
    static let shared = ConfigurationManager()
    @Published var config: AppConfig
    
    init() {
        self.config = AppConfig.load()
    }
    
    func updateConfig(_ updates: @escaping (inout AppConfig) -> Void) {
        var updatedConfig = config
        updates(&updatedConfig)
        config = updatedConfig
        
        do {
            try config.save()
        } catch {
            print("Failed to save configuration: \(error)")
        }
    }
}
