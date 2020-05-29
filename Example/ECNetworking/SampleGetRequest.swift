import ECNetworking

struct SampleGetRequest {}

struct SampleGetResponse: Codable {
    let args: [String: String]
    let headers: [String: String]
    let url: String
}

extension SampleGetRequest: Request {
    
    typealias Response = SampleGetResponse
    
    var data: Encodable? { nil }
    var headers: Headers { [:] }
    var method: RequestMethod { .get }
    
    func buildURL(with baseURL: URL) -> URL {
        baseURL
            .appendingPathComponent("get")
            .appendingQueryParameters([
                "foo": "bar"
            ])
    }
}
