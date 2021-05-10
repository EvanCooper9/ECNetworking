import ECNetworking
import Foundation

struct MockVoidRequest: Request {
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .get, url: baseURL)
    }
}

struct MockDataRequest: Request {
    
    typealias Response = Data
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .get, url: baseURL)
    }
}
