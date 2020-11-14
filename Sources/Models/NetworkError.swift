import Foundation

public enum NetworkError: LocalizedError {
    
    // HTTP 400s
    case badRequest(Data?)
    case paymentRequired(Data?)
    case unauthorized(Data?)
    case forbidden(Data?)
    case notFound(Data?)
    case unprocessible(Data?)
    
    // HTTP 500s
    case internalServer
    
    case unknown
    
    init?(from statusCode: Int, data: Data? = nil) {
        switch statusCode {
        case 400: self = .badRequest(data)
        case 401: self = .unauthorized(data)
        case 402: self = .paymentRequired(data)
        case 403: self = .forbidden(data)
        case 404: self = .notFound(data)
        case 422: self = .unprocessible(data)
        case 500: self = .internalServer
        default: return nil
        }
    }
    
    public var data: Data? {
        switch self {
        case .badRequest(let data),
             .unauthorized(let data),
             .paymentRequired(let data),
             .forbidden(let data),
             .notFound(let data),
             .unprocessible(let data):
            return data
        case .internalServer,
             .unknown:
            return nil
        }
    }
}
