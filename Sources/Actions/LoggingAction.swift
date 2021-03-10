import Foundation

struct LoggingAction {
    func description(for request: NetworkRequest) -> String {
        var description = "\n---------- BEGIN REQUEST ----------\n"
        description.append("URL: \(request.url.absoluteString)")
        description.append("\ncurl -X \(request.method) \"\(request.url.absoluteString)\"")
        request.headers.forEach {
            description.append(" -H \"\($0): \($1)\"")
        }
        description.append(" -g --verbose")
        if let data = try? request.body?.encoded(), let bodyString = String(data: data, encoding: .utf8) {
            description.append(" -d '\(bodyString)'")
        }
        description.append("\n---------- END REQUEST ----------\n")
        return description
    }
    
    func description(for response: NetworkResponse, error: Error? = nil) -> String {
        var description = "\n---------- BEGIN RESPONSE ----------\n"
        description.append("URL: \(response.response.url?.absoluteString ?? "-")")
        description.append("\nStatus code: \(response.response.statusCode)")
        
        if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
            description.append("\nData: \(dataString)")
        }
        
        if let error = error {
            description.append("\nError: \(error.localizedDescription)")
        }
        
        description.append("\n---------- END RESPONSE ----------\n")
        return description
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
