import Foundation

struct LoggingAction {}

extension LoggingAction: RequestBeganAction {
    func requestBegan(_ request: URLRequest) {
        print(description(for: request))
    }
    
    func description(for request: URLRequest) -> String {
        guard let url = request.url,
            let method = request.httpMethod,
            let headers = request.allHTTPHeaderFields else {
                return ""
        }
        
        var description = "\n---------- BEGIN REQUEST ----------\n"
        description.append("URL: \(url.absoluteString)")
        description.append("\ncurl -X \(method) \"\(url.absoluteString)\"")
        headers.forEach { key, value in
            description.append(" -H \"\(key): \(value)\"")
        }
        description.append(" -g --verbose")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            description.append(" -d '\(bodyString)'")
        }
        description.append("\n---------- END REQUEST ----------\n")
        return description
    }
}

extension LoggingAction: ResponseCompletedAction {
    
    func responseReceived(request: NetworkRequest, result: NetworkResult, completion: @escaping (Result<NetworkResult, Error>) -> Void) {
        switch result {
        case .failure(let response, let error):
            print(description(for: response, error: error))
        case .success(let response):
            print(description(for: response))
        }
        completion(.success(result))
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
