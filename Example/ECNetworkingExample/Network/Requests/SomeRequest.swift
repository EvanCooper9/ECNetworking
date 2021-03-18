import ECNetworking
import Foundation

struct SomeRequest {}

extension SomeRequest: CustomRequest {
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        .init(method: .get, url: baseURL.appendingPathComponent("get"))
    }
}
