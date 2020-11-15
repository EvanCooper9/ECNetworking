import Foundation

extension UserDefaults {
    var authenticated: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
