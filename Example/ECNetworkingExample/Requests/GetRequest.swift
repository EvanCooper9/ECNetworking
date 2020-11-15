import ECNetworking
import Foundation

struct GetRequest {}

extension GetRequest: Request {
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL.appendingPathComponent("get")
        return .init(method: .get, url: url)
    }
}
