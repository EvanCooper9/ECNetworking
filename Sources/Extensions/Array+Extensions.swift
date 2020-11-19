import Foundation

extension Array where Element == RequestWillBeginAction {
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void) {
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
                remaining.requestWillBegin(request, completion: completion)
            }
        }
    }
}

extension Array where Element == ResponseCompletedAction {
    func responseCompleted(request: NetworkRequest, response: NetworkResponse, completion: @escaping (Result<NetworkResponse, Error>) -> Void) {
        guard let first = first else {
            completion(.success(response))
            return
        }
        
        first.responseCompleted(request: request, response: response) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                let remaining = Array(self.dropFirst())
                remaining.responseCompleted(request: request, response: response, completion: completion)
            }
        }
    }
}
