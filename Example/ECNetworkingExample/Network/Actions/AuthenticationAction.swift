import ECNetworking
import Foundation

final class AuthenticationAction {
    
    // MARK: - Private Properties
    
    private let network: Network
    private let userDefaults: UserDefaults
    
    private var loginActive = false
    private var loginClosures = [(Result<Void, Error>) -> Void]()
    
    // MARK: - Lifecycle
    
    init(network: Network, userDefaults: UserDefaults = .standard) {
        self.network = network
        self.userDefaults = userDefaults
    }
}

extension AuthenticationAction: RequestWillBeginAction {
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping RequestCompletion) {
        guard !request.isAuthenticationRequest, !userDefaults.authenticated else {
            completion(.success(request))
            return
        }
        
        guard !loginActive else {
            loginClosures.append { self.handle($0, for: request, with: completion) }
            return
        }
        
        loginActive = true
        network.send(AuthenticationRequest()) { [weak self] result in
            guard let self = self else { return }
            self.handle(result, for: request, with: completion)
            self.loginClosures.forEach { $0(result) }
            self.loginActive = false
        }
    }
    
    private func handle(_ result: Result<Void, Error>, for request: NetworkRequest, with completion: @escaping RequestCompletion) {
        switch result {
        case .failure(let error):
            completion(.failure(error))
        case .success:
            userDefaults.authenticated = true
            completion(.success(request))
        }
    }
}
