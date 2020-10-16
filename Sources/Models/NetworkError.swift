import Foundation

public enum NetworkError: LocalizedError {
    
    struct Detail: Decodable {
        let errors: [String]
    }
    
    // HTTP 400s
    case badRequest(Data?)
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
        case 403: self = .forbidden(data)
        case 404: self = .notFound(data)
        case 422: self = .unprocessible(data)
        case 500: self = .internalServer
        default: return nil
        }
    }
    
    public var errorDescription: String? { localizedDescription }
    
    public var localizedDescription: String {
        switch self {
        case .badRequest(let data),
             .unauthorized(let data),
             .forbidden(let data),
             .notFound(let data),
             .unprocessible(let data):
            
            guard let data = data else {
                return "Unknown network error."
            }
            
            let detail = try? JSONDecoder().decode(Detail.self, from: data)
            return detail?.errors.first ?? "Unknown network error"
        case .internalServer:
            return "Server error."
        case .unknown:
            return "Unknown network error."
        }
    }
}
