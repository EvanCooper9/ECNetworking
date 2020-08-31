extension Array where Element == RequestWillBeginAction {
    func requestWillBegin(with request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void) {
        guard let first = first else {
            completion(.success(request))
            return
        }
        
        first.requestWillBegin(request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let request):
                let remaining = Array(self.dropFirst())
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
    
    func responseReceived(request: NetworkRequest, result: NetworkResult, completion: @escaping (Result<NetworkResult, Error>) -> Void) {
        guard let first = first else {
            completion(.success(result))
            return
        }
        
        first.responseReceived(request: request, result: result) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let result):
                let remaining = Array(self.dropFirst())
                remaining.responseReceived(request: request, result: result, completion: completion)
            }
        }
    }
}
