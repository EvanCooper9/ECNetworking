import ECNetworking

struct AuthenticationRequest {}

extension AuthenticationRequest: Request {
    
    var customProperties: [AnyHashable : Any] {
        [CustomPropertyKeys.requiresAuthentication: false]
    }
    
    func bulidRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .post, url: baseURL.appendingPathComponent("post"))
    }
}
