public struct NetworkRequest {
    
    public enum Method: String {
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    public var headers: Headers
    public var method: Method
    public var url: URL
    public var body: Encodable?
    
    public var customProperties: [AnyHashable: Any]!
    
    public init(headers: Headers = [:], method: Method, url: URL, body: Encodable? = nil) {
        self.headers = headers
        self.method = method
        self.url = url
        self.body = body
    }
}

extension NetworkRequest {
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        
        if let data = try? body?.encoded() {
            request.httpBody = data
        }
        
        return request
    }
}
