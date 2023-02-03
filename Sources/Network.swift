import Combine
import Foundation

public protocol Network {
    
    typealias Priority = Operation.QueuePriority
    
    func add(action: Action)
    
    @discardableResult
    func send<T: Request>(_ request: T, withPriority priority: Priority, completion: ((Result<T.Response, Error>) -> Void)?) -> Cancellable
}

public extension Network {
    
    @discardableResult
    func send<T: Request>(_ request: T, withPriority priority: Priority = .normal, completion: ((Result<T.Response, Error>) -> Void)? = nil) -> Cancellable {
        send(request, withPriority: priority, completion: completion)
    }
}

public extension Network {
    func send<T: Request>(_ request: T, withPriority priority: Priority = .normal) -> AnyPublisher<T.Response, Error> {
        let subject = PassthroughSubject<T.Response, Error>()
        let cancellable = self.send(request, withPriority: priority) { result in
            switch result {
            case .failure(let error):
                subject.send(completion: .failure(error))
            case .success(let response):
                subject.send(response)
                subject.send(completion: .finished)
            }
        }
        return subject
            .handleEvents(receiveCancel: { [cancellable] in cancellable.cancel() })
            .eraseToAnyPublisher()
    }
}

public extension Network {
    func send<T: Request>(_ request: T, withPriority priority: Priority = .normal) async throws -> T.Response {
        try await withCheckedThrowingContinuation { continuation in
            send(request, withPriority: priority) { result in
                continuation.resume(with: result)
            }
        }
    }
}
