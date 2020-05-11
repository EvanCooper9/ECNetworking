import ECNetworking
import UIKit

class ViewController: UIViewController {
    
    private let requestSender: RequestSending = RequestSender()
    private let userDefaults: UserDefaults = .standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authenticationAction = AuthenticationAction(userDefaults: userDefaults)
        let loggingAction = LoggingAction()
        
        requestSender.add(action: authenticationAction)
        requestSender.add(action: loggingAction)
    }
    
    @IBAction func sendRequestButtonTapped(_ sender: Any) {
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
    
    @IBAction func clearAuthButtonTapped(_ sender: Any) {
        userDefaults.authentication = false
    }
}

extension UserDefaults {
    var authentication: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
