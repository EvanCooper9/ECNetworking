import XCTest

@testable import ECNetworking

final class NetworkRequestTests: XCTestCase {
    
    private var encoder: JSONEncoder!
    
    override func setUp() {
        super.setUp()
        encoder = JSONEncoder()
    }
    
    func testThatAsUrlRequestWorks() {
        let headers = ["Key": "Value"]
        let method = NetworkRequest.Method.get
        let body = Data()
        
        let networkRequest = NetworkRequest(
            headers: headers,
            method: method,
            url: .mock,
            body: body
        )
        
        let urlRequest = networkRequest.asURLRequest(with: encoder)
        
        XCTAssertEqual(urlRequest.httpMethod, method.rawValue)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, headers)
        XCTAssertEqual(urlRequest.httpBody, try? body.encoded(using: encoder))
    }
}
