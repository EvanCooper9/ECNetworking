import ECNetworking
import Foundation

struct AuthenticationRequest {
    let username = "user"
    let password = "pass"
}

extension AuthenticationRequest: Request {
    
    var customProperties: [AnyHashable : Any] {
        ["auth": true]
    }
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL.appendingPathComponent("post")
        return .init(method: .post, url: url, body: self)
    }
}
