import Foundation

struct LoggingAction {}

extension LoggingAction: RequestBeganAction {
    public func requestBegan(_ request: URLRequest) {
        print(description(for: request))
    }
    
    private func description(for request: URLRequest) -> String {
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

extension LoggingAction: ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: HTTPURLResponse) {
        print(description(response: response))
    }
    
    private func description(response: HTTPURLResponse) -> String {
        var description = "\n---------- BEGIN RESPONSE ----------\n"
        description.append("\(response)")
        description.append("\n---------- END RESPONSE ----------\n")
        return description
    }
}

extension LoggingAction: ResponseCompletedAction {
    
    func responseReceived(request: NetworkRequest, result: NetworkResult, completion: @escaping (Result<NetworkResult, Error>) -> Void) {
        switch result {
        case .failure(let response, let error):
            printResponseData(data: response.data)
            print("Error: \(error.localizedDescription)")
        case .success(let response):
            printResponseData(data: response.data)
        }
        completion(.success(result))
    }
    
    private func printResponseData(data: Data?) {
        if let data = data, let dataString = String(data: data, encoding: .utf8) {
            print("Data: \(dataString)")
        }
    }
}
