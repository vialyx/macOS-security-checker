import SwiftUI

struct DetailedCheckView: View {
    let result: SecurityCheckResult
    @State private var showRemediation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: result.check.status == .pass ? "checkmark.circle.fill" :
                      result.check.status == .fail ? "xmark.circle.fill" :
                      result.check.status == .warning ? "exclamationmark.circle.fill" : "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(Color(result.check.status.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.check.name)
                        .font(.headline)
                    Text(result.check.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(result.check.status.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text("Severity: \(result.check.severity)/5")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(result.check.description)
                    .font(.body)
            }
            
            // Details
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Details")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text(result.details)
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)
                        .lineLimit(5)
                }
            }
            
            // Remediation
            if let remediation = result.check.remediation {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("How to Fix")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(remediation, forType: .string)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .help("Copy to clipboard")
                    }
                    
                    Text(remediation)
                        .font(.body)
                        .padding(8)
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(4)
                }
            }
            
            // API Information
            if !result.check.apis.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("APIs Used")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(result.check.apis, id: \.self) { api in
                            Text(api)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
            
            // Enforceability
            HStack {
                Label(
                    result.check.enforceable ? "Can be enforced" : "Cannot be enforced",
                    systemImage: result.check.enforceable ? "checkmark.seal.fill" : "xmark.seal.fill"
                )
                .font(.caption)
                .foregroundColor(result.check.enforceable ? .green : .orange)
                
                Spacer()
                
                if result.requiresElevation {
                    Label("Requires sudo", systemImage: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                if result.check.enforceable && result.check.status == .fail {
                    Button(action: {
                        // TODO: Implement remediation
                        print("Attempting to fix: \(result.check.name)")
                    }) {
                        Label("Fix Issue", systemImage: "wand.and.stars")
                    }
                    .keyboardShortcut("f", modifiers: [.command])
                }
                
                Button(action: {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(result.details, forType: .string)
                }) {
                    Label("Export Details", systemImage: "arrow.up.doc")
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ComplianceReportView: View {
    let report: SecurityReport
    @State private var selectedBenchmark: ComplianceBenchmark = .cis
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Compliance & Posture Assessment")
                    .font(.headline)
                
                Text(report.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Benchmark Selector
            Picker("Benchmark", selection: $selectedBenchmark) {
                Text("CIS macOS Benchmark").tag(ComplianceBenchmark.cis)
                Text("NIST 800-53").tag(ComplianceBenchmark.nist80053)
                Text("NIST 800-171").tag(ComplianceBenchmark.nist80171)
                Text("SOC 2 Type II").tag(ComplianceBenchmark.soc2)
                Text("Zero Trust Model").tag(ComplianceBenchmark.zeroTrust)
            }
            .pickerStyle(.segmented)
            
            // Compliance Score
            VStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    
                    Circle()
                        .trim(from: 0, to: report.overallScore / 100)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: report.overallScore)
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.0f", report.overallScore))
                            .font(.system(size: 36, weight: .bold))
                        Text("Compliance Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 120)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            
            // Controls
            HStack(spacing: 12) {
                Text("macOS \(report.osVersion)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: {
                    do {
                        let path = try ReportGenerator.shared.saveReport(report, format: .json)
                        print("Report saved to: \(path)")
                    } catch {
                        print("Error: \(error)")
                    }
                }) {
                    Label("Export", systemImage: "arrow.up.doc")
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    var scoreColor: Color {
        if report.overallScore >= 80 {
            return .green
        } else if report.overallScore >= 50 {
            return .orange
        } else {
            return .red
        }
    }
}

@available(macOS 13.0, *)
struct SettingsView: View {
    @State private var scanInterval: Double
    
    init() {
        _scanInterval = State(initialValue: Double(ConfigurationManager.shared.config.scanInterval))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
            
            Form {
                Section("Scanning") {
                    Stepper(
                        "Scan Interval: \(Int(scanInterval))s",
                        value: $scanInterval,
                        in: 300...86400,
                        step: 300
                    )
                    .onChange(of: scanInterval) { newValue in
                        ConfigurationManager.shared.updateConfig { $0.scanInterval = Int(newValue) }
                    }
                    
                    Text("Alerts enabled by default")
                }
                
                Section("Compliance") {
                    Text("CIS Benchmark selected")
                    .onChange(of: scanInterval) { _ in
                        ConfigurationManager.shared.updateConfig { $0.complianceBenchmark = .cis }
                    }
                }
                
                Section("Advanced") {
                    Text("MDM Enabled")
                        .onChange(of: scanInterval) { _ in
                            ConfigurationManager.shared.updateConfig { $0.mdmEnabled = true }
                        }
                    
                    Text("Auto Remediation Enabled")
                        .onChange(of: scanInterval) { _ in
                            ConfigurationManager.shared.updateConfig { $0.autoRemediationEnabled = true }
                        }
                }
            }
        }
        .padding()
    }
}
