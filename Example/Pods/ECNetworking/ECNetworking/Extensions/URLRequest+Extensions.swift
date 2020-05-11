extension URLRequest {
    init<T: Request>(request: T) {
        self = .init(url: request.url)
        self.httpMethod = request.method.rawValue
        
        if request.method != .get, let body = try? request.encoded() {
            self.httpBody = body
        }
        
        request.headers.forEach { header, value in
            self.addValue(value, forHTTPHeaderField: header)
        }
    }
}
