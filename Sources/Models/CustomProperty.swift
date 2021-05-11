public protocol CustomPropertyContaining {
    
    typealias CustomProperties = [AnyHashable: Any]
    
    var customProperties: CustomProperties { get }
}
