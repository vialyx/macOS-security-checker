import SwiftUI

@main
struct SecurityCheckerApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 700)
        }
    }
}

struct MainView: View {
    @State private var checks: [SecurityCheck] = []
    @State private var isRunning = false
    @State private var overallScore: Double = 0
    private let manager = SecurityCheckManager()
    
    var passedCount: Int {
        checks.filter { $0.status == .pass }.count
    }
    
    var warningCount: Int {
        checks.filter { $0.status == .warning }.count
    }
    
    var failedCount: Int {
        checks.filter { $0.status == .fail }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🛡️ MacOS Security Checker")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Security Assessment Tool")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isRunning {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Scanning...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .border(Color(.separatorColor), width: 1)
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Status Cards
                    if !checks.isEmpty {
                        HStack(spacing: 12) {
                            StatusCard(title: "Passed", count: passedCount, color: .green)
                            StatusCard(title: "Warnings", count: warningCount, color: .orange)
                            StatusCard(title: "Failed", count: failedCount, color: .red)
                        }
                        
                        // Score
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Overall Security Score")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "%.0f%%", overallScore))
                                    .font(.headline)
                                    .foregroundColor(overallScore >= 80 ? .green : overallScore >= 60 ? .orange : .red)
                            }
                            ProgressView(value: min(overallScore / 100.0, 1.0))
                        }
                        .padding()
                        .background(Color(.controlBackgroundColor))
                        .cornerRadius(8)
                        
                        Divider()
                    }
                    
                    // Buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Actions")
                            .font(.headline)
                        
                        Button(action: runScan) {
                            HStack {
                                Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                                Text(isRunning ? "Stop Scan" : "Run Security Check")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.bordered)
                        .disabled(isRunning)
                    }
                    
                    Divider()
                    
                    // List
                    if !checks.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Security Checks")
                                    .font(.headline)
                                Spacer()
                                Text("\(checks.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(checks, id: \.id) { check in
                                    CheckRow(check: check)
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.shield")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Ready to Start")
                                .font(.headline)
                            Text("Click the button above to run a security check")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            loadInitialData()
        }
    }
    
    private func loadInitialData() {
        checks = manager.checks
    }
    
    private func runScan() {
        guard !isRunning else { return }
        
        isRunning = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            manager.runAllChecks { report in
                DispatchQueue.main.async {
                    self.checks = self.manager.checks
                    self.overallScore = report?.overallScore ?? 0
                    self.isRunning = false
                }
            }
        }
    }
}

struct StatusCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

struct CheckRow: View {
    let check: SecurityCheck
    @State private var showHint = false
    
    var icon: String {
        switch check.status {
        case .pass: return "✅"
        case .warning: return "⚠️"
        case .fail: return "❌"
        case .unknown: return "❓"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Text(icon).font(.body)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(check.name).font(.body).fontWeight(.medium)
                    Text(check.description).font(.caption).foregroundColor(.secondary).lineLimit(1)
                }
                
                Spacer()
                
                Text(check.category.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
                
                if check.hint != nil {
                    Button(action: { showHint.toggle() }) {
                        Image(systemName: showHint ? "chevron.up" : "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(8)
            
            if showHint, let hint = check.hint {
                Divider()
                Text(hint)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
    }
}
