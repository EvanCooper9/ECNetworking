import ECNetworking

public protocol ExampleAppRequest {
    var requiresAuthentication: Bool { get }
}

@dynamicMemberLookup
struct Compose<Element1, Element2> {
    var element1: Element1
    var element2: Element2
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Element1, T>) -> T {
        get { element1[keyPath: keyPath] }
        set { element1[keyPath: keyPath] = newValue }
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Element2, T>) -> T {
        get { element2[keyPath: keyPath] }
        set { element2[keyPath: keyPath] = newValue }
    }
    
    init(_ element1: Element1, _ element2: Element2) {
        self.element1 = element1
        self.element2 = element2
    }
}

typealias ExampleNetworkRequest = Compose<NetworkRequest, ExampleAppRequest>
