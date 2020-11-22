import Foundation

final class MockURLSession: URLSession {
    
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        MockURLSessionDataTask { [data, response, error] in
            completionHandler(data, response, error)
        }
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        MockURLSessionDataTask { [data, response, error] in
            completionHandler(data, response, error)
        }
    }
}
