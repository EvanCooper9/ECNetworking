import ECNetworking
import Foundation

struct MockRequest: Request {
    
    var customProperties: [AnyHashable : Any] { [:] }
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .get, url: baseURL)
    }
}
