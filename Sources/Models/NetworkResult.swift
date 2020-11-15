public enum NetworkResult {
    case success(NetworkResponse)
    case failure(NetworkResponse, Error)
}
