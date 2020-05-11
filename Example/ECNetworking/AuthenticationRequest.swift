import ECNetworking

struct AuthenticationRequest {}

extension AuthenticationRequest: Request {
    
    typealias Response = Void
    
    var data: Encodable? { nil }
    var headers: Headers { [:] }
    var method: RequestMethod { .get }
    
    var url: URL {
        URL(string: "https://postman-echo.com")!
            .appendingPathComponent("post")
    }
}
