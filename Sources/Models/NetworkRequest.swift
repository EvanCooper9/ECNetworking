import Foundation

public struct NetworkRequest: CustomPropertyContaining {
    
    public typealias Headers = [String: CustomStringConvertible]
    
    public enum Method: String {
        case get = "GET"
        case head = "HEAD"
        case options = "OPTIONS"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    // MARK: - Public Properties
    
    public var headers: Headers
    public var method: Method
    public var url: URL
    public var body: Encodable?
    public var customProperties: CustomProperties
    
    public init(headers: Headers = [:], method: Method, url: URL, body: Encodable? = nil, customProperties: CustomProperties = [:]) {
        self.headers = headers
        self.method = method
        self.url = url
        self.body = body
        self.customProperties = customProperties
    }
}

extension NetworkRequest {
    func asURLRequest(with encoder: JSONEncoder) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers.mapValues(\.description)

        if let data = try? body?.encoded(using: encoder) {
            request.httpBody = data
        }
        
        return request
    }
}
