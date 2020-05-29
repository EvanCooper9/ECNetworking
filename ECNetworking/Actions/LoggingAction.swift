public struct LoggingAction {
    public var sender: Networking?
    public init() {}
}

extension LoggingAction: RequestAction {
    public func requestWillBegin(_ request: URLRequest, completion: (Result<URLRequest, Error>) -> Void) {
        print(description(for: request))
        completion(.success(request))
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

extension LoggingAction: ResponseAction {
    public func responseReceived<T: Request>(sender: Networking, request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping ResponseActionClosure<T>) {
        if let responseBody = responseBody as? Encodable {
            print(description(for: responseBody, response: response))
        }
        completion(.success(responseBody))
    }
    
    private func description(for responseBody: Encodable, response: HTTPURLResponse) -> String {
        var description = "\n---------- BEGIN RESPONSE ----------\n"
        description.append("\(response)")
        if let dataString = try? responseBody.encodedToString() {
            description.append("\nData: \(dataString))")
        }
        description.append("\n---------- END RESPONSE ----------\n")
        return description
    }
}
