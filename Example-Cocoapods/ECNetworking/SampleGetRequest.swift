import ECNetworking

struct SampleGetResponse: Codable {
    let args: [String: String]
    let headers: [String: String]
    let url: String
}

struct SampleGetRequest {}

extension SampleGetRequest: Request {
    
    typealias Response = SampleGetResponse
    
    func buildRequest(with baseURL: URL) -> NetworkRequest {
        let url = baseURL
            .appendingPathComponent("get")
            .appendingQueryParameters([
                "foo": "bar"
            ])
        
        return .init(method: .get, url: url)
    }
}
