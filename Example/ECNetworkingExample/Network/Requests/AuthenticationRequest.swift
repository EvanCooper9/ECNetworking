import ECNetworking
import Foundation

struct AuthenticationRequest: Encodable {
    let user = "evan@example.com"
    let pass = "password"
}

extension AuthenticationRequest: CustomRequest {
    
    var isAuthenticationRequest: Bool { true }
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .post, url: baseURL.appendingPathComponent("post"), body: self)
    }
}
