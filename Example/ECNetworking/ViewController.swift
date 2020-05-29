import ECNetworking
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private lazy var requestSender: Networking = {
        let configuration = NetworkConfiguration(
            baseURL: URL(string: "https://postman-echo.com")!,
            logging: true
        )
        
        return Network(configuration: configuration)
    }()
    
    private let userDefaults: UserDefaults = .standard
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticationAction = AuthenticationAction(userDefaults: userDefaults)
        requestSender.add(action: authenticationAction)
    }
    
    // MARK: - Private Methods
    
    @IBAction private func sendRequestButtonTapped(_ sender: Any) {
        let request = SampleGetRequest()
        requestSender.send(request) { result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                print(response)
            }
        }
    }
    
    @IBAction private func clearAuthButtonTapped(_ sender: Any) {
        userDefaults.authentication = false
    }
}

extension UserDefaults {
    var authentication: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
