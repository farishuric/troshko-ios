import Foundation

// sourcery: AutoMockable
public protocol NetworkInterceptor {
    func adapt(_ request: URLRequest) async throws -> URLRequest
    func retry(_ request: URLRequest, dueTo response: HTTPURLResponse, data: Data) async throws -> URLRequest?
}
