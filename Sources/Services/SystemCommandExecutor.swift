import Foundation

class SystemCommandExecutor {
    static let shared = SystemCommandExecutor()
    
    func execute(_ command: String, arguments: [String] = []) -> (output: String, error: String, exitCode: Int32) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""
            
            return (output.trimmingCharacters(in: .whitespacesAndNewlines),
                    error.trimmingCharacters(in: .whitespacesAndNewlines),
                    process.terminationStatus)
        } catch {
            return ("", error.localizedDescription, 1)
        }
    }
    
    func shell(_ command: String) -> (output: String, error: String, exitCode: Int32) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            
            // Add timeout to prevent hanging
            let deadline = Date(timeIntervalSinceNow: 5) // 5 second timeout
            while process.isRunning && Date() < deadline {
                usleep(100000) // Sleep 100ms
            }
            
            if process.isRunning {
                process.terminate()
                return ("", "Command timeout", 124)
            }
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8) ?? ""
            let error = String(data: errorData, encoding: .utf8) ?? ""
            
            return (output.trimmingCharacters(in: .whitespacesAndNewlines),
                    error.trimmingCharacters(in: .whitespacesAndNewlines),
                    process.terminationStatus)
        } catch {
            return ("", error.localizedDescription, 1)
        }
    }
    
    func requiresElevation(for command: String) -> Bool {
        // Check if command requires sudo by attempting to run and checking for permission denied
        let result = shell(command)
        return result.error.lowercased().contains("permission denied") ||
               result.error.lowercased().contains("operation not permitted")
    }
}
