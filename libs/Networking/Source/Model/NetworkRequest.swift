import Foundation

public protocol NetworkRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var queryParameters: [String: String]? { get }
}

public extension NetworkRequest {
    var queryParameters: [String: String]? { nil }
}
