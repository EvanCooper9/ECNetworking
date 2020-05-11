public protocol Request: Encodable {
    
    associatedtype Response
    
    var headers: Headers { get }
    var method: RequestMethod { get }
    var url: URL { get }
    
    func response(from data: Data) throws -> Response
}

extension Request where Response: Decodable {
    public func response(from data: Data) throws -> Response {
        let decoder = JSONDecoder()
        return try decoder.decode(Response.self, from: data)
    }
}

extension Request where Response == Void {
    public func response(from data: Data) throws {}
}
