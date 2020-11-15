import ECNetworking
import Foundation

struct AuthenticationAction {
    
    // MARK: - Private Properties
    
    private let network: Networking
    private let userDefaults: UserDefaults
    
    // MARK: - Lifecycle
    
    init(network: Networking, userDefaults: UserDefaults = .standard) {
        self.network = network
        self.userDefaults = userDefaults
    }
}

extension AuthenticationAction: RequestWillBeginAction {
    func requestWillBegin(_ request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void) {
        guard !request.isAuthenticationRequest, !userDefaults.authenticated else {
            completion(.success(request))
            return
        }
        
        network.send(AuthenticationRequest()) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                userDefaults.authenticated = true
                completion(.success(request))
            }
        }
    }
}

extension NetworkRequest {
    var isAuthenticationRequest: Bool {
        customProperties.keys
            .compactMap { $0 as? String }
            .contains("auth")
    }
}
