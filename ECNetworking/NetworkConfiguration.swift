public struct NetworkConfiguration {
    let baseURL: URL
    let logging: Bool
    
    public init(baseURL: URL, logging: Bool) {
        self.baseURL = baseURL
        self.logging = logging
    }
}
