public enum NetworkError: Int, Error {
    
    // HTTP 400s
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case unprocessible = 422
    
    // HTTP 500s
    case internalServer = 500
    
    case unknown = -1
}
