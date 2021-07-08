import Foundation

@propertyWrapper
public struct Synchronized<Wrapped> {
    
    private let queue = DispatchQueue(
        label: "com.evancooper.ecnetworking.synchonized",
        qos: .utility
    )
    
    private var value: Wrapped
    
    public var wrappedValue: Wrapped {
        get {
            queue.sync {
                print("executing get and returning \(value)")
                return value
            }
        }
        set {
            queue.sync {
                print("executing set and assigning \(newValue)")
                value = newValue
            }
        }
    }
    
    public init(wrappedValue: Wrapped) {
        value = wrappedValue
    }
}
