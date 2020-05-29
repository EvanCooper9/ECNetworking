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
        if let body = request.httpBody, let data = try? body.encoded() {
            description.append(" -d '\(String(decoding: data, as: UTF8.self))'")
        }
        description.append("\n---------- END REQUEST ----------\n")
        return description
    }
}

extension LoggingAction: ResponseBeganAction {
    public func responseBegan<T: Request>(network: Networking, request: T, response: HTTPURLResponse) {
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
    public func responseReceived<T: Request>(network: Networking, request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping ResponseActionClosure<T>) {
        if let responseBody = responseBody as? Encodable,
            let responseDescription = description(for: responseBody, response: response) {
                print(responseDescription)
        }
        completion(.success(responseBody))
    }
    
    private func description(for responseBody: Encodable, response: HTTPURLResponse) -> String? {
        if let dataString = try? responseBody.encodedToString() {
            return "Data: \(dataString)"
        }
        return nil
    }
}
