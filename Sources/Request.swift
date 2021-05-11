import Foundation

public protocol Request: CustomPropertyContaining, Encodable {
    
    associatedtype Response
        
    func buildRequest(with baseURL: URL) -> NetworkRequest
    func response(from data: Data, with decoder: JSONDecoder) throws -> Response
}

extension Request where Response: Decodable {
    public func response(from data: Data, with decoder: JSONDecoder) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}

extension Request where Response == Void {
    public func response(from data: Data, with decoder: JSONDecoder) throws {}
}

public extension Request {
    var customProperties: CustomProperties { [:] }
}
