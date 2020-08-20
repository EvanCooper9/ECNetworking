public protocol QueryParameterValue {
    func stringValue() -> String
}

extension String: QueryParameterValue {
    public func stringValue() -> String { self }
}

extension Bool: QueryParameterValue {
    public func stringValue() -> String { "\(self)" }
}

public extension URL {
    func appendingQueryParameters(_ queryParameters: [String: QueryParameterValue?]) -> Self {
        guard var urlComponents = URLComponents(string: self.absoluteString) else { return self }
        
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        queryParameters.forEach { key, value in
            guard let value = value else { return }
            let queryItem = URLQueryItem(name: key, value: value.stringValue())
            queryItems.append(queryItem)
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
