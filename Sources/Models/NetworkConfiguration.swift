import Foundation

public struct NetworkConfiguration {
    let baseURL: URL
    let logging: Bool
    let maximumConcurrentRequests: Int?
    
    public init(baseURL: URL, logging: Bool, maximumConcurrentRequests: Int? = nil) {
        self.baseURL = baseURL
        self.logging = logging
        self.maximumConcurrentRequests = maximumConcurrentRequests
    }
}
