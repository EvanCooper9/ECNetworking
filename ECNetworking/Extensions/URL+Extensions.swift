public extension URL {
    func appendingQueryParameters(_ queryParameters: [String: String]) -> Self {
        guard var urlComponents = URLComponents(string: self.absoluteString) else { return self }
        
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        queryParameters.forEach { key, value in
            let queryItem = URLQueryItem(name: key, value: value)
            queryItems.append(queryItem)
        }

        urlComponents.queryItems = queryItems
        return urlComponents.url!
    }
}
