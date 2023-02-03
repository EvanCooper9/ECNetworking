import Combine

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
