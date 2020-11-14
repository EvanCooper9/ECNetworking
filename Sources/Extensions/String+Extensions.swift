import Foundation

extension Encodable {
    public func encodedToString(encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
