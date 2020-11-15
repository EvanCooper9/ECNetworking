import Foundation

extension Encodable {
    public func encoded(using encoder: JSONEncoder = .init()) throws -> Data {
        try encoder.encode(self)
    }
    
    public func encodedToString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
