import Foundation

class ReportGenerator {
    static let shared = ReportGenerator()
    
    func generateJSON(from report: SecurityReport) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(report)
        guard let json = String(data: data, encoding: .utf8) else {
            throw ReportError.encodingFailed
        }
        return json
    }
    
    func generateCSV(from report: SecurityReport) -> String {
        var csv = "Category,Check Name,Status,Severity,Remediation\n"
        
        for result in report.checks {
            let fields = [
                result.check.category.rawValue,
                result.check.name,
                result.check.status.rawValue,
                String(result.check.severity),
                result.check.remediation ?? "N/A"
            ]
            
            let escapedFields = fields.map { field in
                if field.contains(",") || field.contains("\"") {
                    return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return field
            }
            
            csv += escapedFields.joined(separator: ",") + "\n"
        }
        
        return csv
    }
    
    func generateHTML(from report: SecurityReport) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        let scoreColor: String
        if report.overallScore >= 80 {
            scoreColor = "#00CC44"
        } else if report.overallScore >= 50 {
            scoreColor = "#FF9900"
        } else {
            scoreColor = "#CC0000"
        }
        
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>macOS Security Report</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
                    background: #f5f5f7;
                    color: #333;
                    padding: 20px;
                }
                .container {
                    max-width: 1000px;
                    margin: 0 auto;
                    background: white;
                    border-radius: 12px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    overflow: hidden;
                }
                .header {
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                    color: white;
                    padding: 40px;
                    text-align: center;
                }
                .header h1 {
                    font-size: 28px;
                    margin-bottom: 10px;
                }
                .summary {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 20px;
                    padding: 30px;
                    background: #f9f9f9;
                }
                .summary-card {
                    text-align: center;
                    padding: 20px;
                    border-radius: 8px;
                    background: white;
                    box-shadow: 0 1px 3px rgba(0,0,0,0.05);
                }
                .summary-card .number {
                    font-size: 32px;
                    font-weight: bold;
                    margin-bottom: 5px;
                }
                .summary-card .label {
                    font-size: 14px;
                    color: #666;
                }
                .score-card {
                    text-align: center;
                    padding: 30px;
                    background: white;
                    border-radius: 8px;
                }
                .score-circle {
                    width: 120px;
                    height: 120px;
                    border-radius: 50%;
                    background: \(scoreColor);
                    color: white;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 48px;
                    font-weight: bold;
                    margin: 0 auto 15px;
                }
                .checks {
                    padding: 30px;
                }
                .category {
                    margin-bottom: 30px;
                }
                .category-title {
                    font-size: 18px;
                    font-weight: 600;
                    color: #333;
                    margin-bottom: 15px;
                    padding-bottom: 10px;
                    border-bottom: 2px solid #e0e0e0;
                }
                .check {
                    display: flex;
                    align-items: flex-start;
                    padding: 12px;
                    margin-bottom: 8px;
                    border-radius: 6px;
                    background: #f9f9f9;
                }
                .check.pass { background: #f0fdf4; border-left: 4px solid #10b981; }
                .check.warning { background: #fffbeb; border-left: 4px solid #f59e0b; }
                .check.fail { background: #fef2f2; border-left: 4px solid #ef4444; }
                .check-icon {
                    font-size: 18px;
                    margin-right: 12px;
                    min-width: 20px;
                }
                .check-content {
                    flex: 1;
                }
                .check-name {
                    font-weight: 500;
                    margin-bottom: 3px;
                }
                .check-remediation {
                    font-size: 13px;
                    color: #666;
                }
                .footer {
                    padding: 20px 30px;
                    background: #f9f9f9;
                    border-top: 1px solid #e0e0e0;
                    font-size: 12px;
                    color: #666;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>🛡️ macOS Security Report</h1>
                    <p>\(dateFormatter.string(from: report.timestamp)) • macOS \(report.osVersion)</p>
                </div>
        
                <div class="summary">
                    <div class="summary-card">
                        <div class="number" style="color: #10b981;">\(report.passedCount)</div>
                        <div class="label">Passed</div>
                    </div>
                    <div class="summary-card">
                        <div class="number" style="color: #f59e0b;">\(report.warningCount)</div>
                        <div class="label">Warnings</div>
                    </div>
                    <div class="summary-card">
                        <div class="number" style="color: #ef4444;">\(report.failedCount)</div>
                        <div class="label">Failed</div>
                    </div>
                    <div class="score-card">
                        <div class="score-circle">\(String(format: "%.0f", report.overallScore))%</div>
                        <div class="label">Security Score</div>
                    </div>
                </div>
        
                <div class="checks">
        """
        
        var lastCategory: SecurityCategory? = nil
        for result in report.checks {
            if result.check.category != lastCategory {
                html += """
                <div class="category">
                    <div class="category-title">\(result.check.category.rawValue)</div>
                """
                lastCategory = result.check.category
            }
            
            let icon: String
            switch result.check.status {
            case .pass:
                icon = "✓"
            case .warning:
                icon = "⚠"
            case .fail:
                icon = "✕"
            case .unknown:
                icon = "?"
            }
            
            let checkClass = result.check.status.rawValue
            let remediation = result.check.remediation ?? ""
            
            html += """
                    <div class="check \(checkClass)">
                        <div class="check-icon">\(icon)</div>
                        <div class="check-content">
                            <div class="check-name">\(result.check.name)</div>
                            <div class="check-remediation">\(remediation)</div>
                        </div>
                    </div>
            """
        }
        
        html += """
                    </div>
                </div>
            </div>
        
            <div class="footer">
                <p>Generated by macOS Security Checker • \(dateFormatter.string(from: report.timestamp))</p>
            </div>
        </body>
        </html>
        """
        
        return html
    }
    
    func saveReport(_ report: SecurityReport, format: ExportFormat = .json) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let reportsPath = documentsPath.appendingPathComponent("Security Reports")
        
        try FileManager.default.createDirectory(at: reportsPath, withIntermediateDirectories: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "Security_Report_\(dateFormatter.string(from: report.timestamp))"
        
        var fileURL: URL
        var content: String
        
        switch format {
        case .json:
            fileURL = reportsPath.appendingPathComponent(filename).appendingPathExtension("json")
            content = try generateJSON(from: report)
        case .csv:
            fileURL = reportsPath.appendingPathComponent(filename).appendingPathExtension("csv")
            content = generateCSV(from: report)
        case .pdf:
            // PDF generation would require additional libraries
            fileURL = reportsPath.appendingPathComponent(filename).appendingPathExtension("html")
            content = generateHTML(from: report)
        }
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}

enum ReportError: LocalizedError {
    case encodingFailed
    case writeFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode report to JSON"
        case .writeFailed:
            return "Failed to write report to file"
        }
    }
}
