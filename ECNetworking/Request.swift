public protocol Request: Encodable {
    
    associatedtype Response
    
    var headers: Headers { get set }
    var method: RequestMethod { get }
    var requiresAuthentication: Bool { get }
    
    func buildURL(with baseURL: URL) -> URL
    func response(from data: Data, with decoder: JSONDecoder) throws -> Response
}

extension Request where Response: Decodable {
    public func response(from data: Data, with decoder: JSONDecoder) throws -> Response {
        return try decoder.decode(Response.self, from: data)
    }
}

extension Request where Response == Void {
    public func response(from data: Data, with decoder: JSONDecoder) throws {}
}
