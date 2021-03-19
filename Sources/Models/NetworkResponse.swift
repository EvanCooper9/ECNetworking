import Foundation

public struct NetworkResponse {
    public let response: HTTPURLResponse
    public let data: Data?
}

public extension NetworkResponse {
    var statusCode: Int { response.statusCode }
}
