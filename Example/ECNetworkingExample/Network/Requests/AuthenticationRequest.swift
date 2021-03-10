import ECNetworking
import Foundation

struct AuthenticationRequest {}

extension AuthenticationRequest: CustomRequest {
    
    var isAuthenticationRequest: Bool { true }
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL.appendingPathComponent("get")
        return .init(method: .get, url: url)
    }
}
