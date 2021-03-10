import ECNetworking
import Foundation

struct SomeRequest {}

extension SomeRequest: CustomRequest {
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL.appendingPathComponent("get")
        return .init(method: .get, url: url)
    }
}
