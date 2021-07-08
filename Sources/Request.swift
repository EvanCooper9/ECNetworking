import Foundation

public protocol Request: CustomPropertyContaining {
    
    associatedtype Response
        
    func buildRequest(with baseURL: URL) -> NetworkRequest
    func response(from data: Data, with decoder: JSONDecoder) throws -> Response
}

public extension Request where Response: Decodable {
    func response(from data: Data, with decoder: JSONDecoder) throws -> Response {
        try decoder.decode(Response.self, from: data)
    }
}

public extension Request where Response == Void {
    func response(from data: Data, with decoder: JSONDecoder) throws {}
}

public extension Request where Response == Data {
    func response(from data: Data, with decoder: JSONDecoder) throws -> Response { data }
}

public extension Request {
    var customProperties: CustomProperties { [:] }
}
