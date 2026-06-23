import Foundation

// sourcery: AutoMockable
public protocol NetworkProvider {
    func request<T: Decodable>(_ request: NetworkRequest) async throws -> T
    func request(_ request: NetworkRequest) async throws

    func get(url: String,
             headers: [String: String]?,
             queryParameters: [String: String]?) async throws -> Data
}
