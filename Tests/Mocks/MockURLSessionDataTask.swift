import Foundation

final class MockURLSessionDataTask: URLSessionDataTask {
    
    // MARK: - Public Properties
    
    private(set) var didCancel = false
    
    // MARK: - Private Properties
    
    private let closure: () -> Void
    
    // MARK: - Lifecycle
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // MARK: - Overrides
    
    override func resume() {
        closure()
    }
    
    override func cancel() {
        didCancel = true
    }
}
