import Foundation

struct LoggingAction {
    
    let encoder: JSONEncoder
    
    func description(for request: NetworkRequest) -> String {
        var description = [String]()
        description.append("---------- BEGIN REQUEST ----------")
        description.append("URL: \(request.url.absoluteString)")
        
        var command = "curl -X \(request.method) \"\(request.url.absoluteString)\""
        request.headers.forEach { command.append(" -H \"\($0): \($1)\"") }
        command.append(" -g --verbose")
        if let data = try? request.body?.encoded(using: encoder), let bodyString = String(data: data, encoding: .utf8) {
            command.append(" -d '\(bodyString)'")
        }
        
        description.append(command)
        description.append("---------- END REQUEST ----------")
        description.insert("", at: 0)
        description.append("")
        return description.joined(separator: "\n")
    }
    
    func description(for response: NetworkResponse) -> String {
        var description = [String]()
        description.append("---------- BEGIN RESPONSE ----------")
        description.append("URL: \(response.response.url?.absoluteString ?? "-")")
        description.append("Status code: \(response.response.statusCode)")
        
        if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
            description.append("Data: \(dataString)")
        }
        
        description.append("---------- END RESPONSE ----------")
        description.insert("", at: 0)
        description.append("")
        return description.joined(separator: "\n")
    }
}

extension LoggingAction: RequestBeganAction {
    func requestBegan(_ request: NetworkRequest) {
        print(description(for: request))
    }
}

extension LoggingAction: ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: NetworkResponse) {
        print(description(for: response))
    }
}
