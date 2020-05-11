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
    
    var url: URL {
        URL(string: "https://postman-echo.com")!
            .appendingPathComponent("get")
            .appendingQueryParameters([
                "foo": "bar"
            ])
    }
}
