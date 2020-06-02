extension Array where Element == RequestWillBeginAction {
    func requestWillBegin(with request: NetworkRequest, completion: (Result<NetworkRequest, Error>) -> Void) {
        guard let first = first else {
            completion(.success(request))
            return
        }
        
        first.requestWillBegin(request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let request):
                let remaining = Array(dropFirst())
                remaining.requestWillBegin(with: request, completion: completion)
            }
        }
    }
}

extension Array where Element == RequestBeganAction {
    func requestBegan(request: URLRequest) {
        forEach { $0.requestBegan(request) }
    }
}

extension Array where Element == ResponseBeganAction {
    func responseBegan(request: NetworkRequest, response: HTTPURLResponse) {
        forEach { $0.responseBegan(request: request, response: response) }
    }
}

extension Array where Element == ResponseCompletedAction {
    func responseReceived<T: Request>(request: T, responseBody: T.Response, response: HTTPURLResponse, completion: @escaping (Result<T.Response, Error>) -> Void) {
        guard let first = first else {
            completion(.success(responseBody))
            return
        }
        
        first.responseReceived(request: request, responseBody: responseBody, response: response) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let newResponseBody):
                let remaining = Array(self.dropFirst())
                remaining.responseReceived(request: request, responseBody: newResponseBody, response: response, completion: completion)
            }
        }
    }
}
