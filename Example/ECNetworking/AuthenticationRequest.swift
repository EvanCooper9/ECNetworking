import ECNetworking

struct AuthenticationRequest {}

extension AuthenticationRequest: Request {
    
    typealias Response = Void
    
    var data: Encodable? { nil }
    var headers: Headers { [:] }
    var method: RequestMethod { .get }
    
    func buildURL(with baseURL: URL) -> URL {
        baseURL.appendingPathComponent("post")
    }
}
