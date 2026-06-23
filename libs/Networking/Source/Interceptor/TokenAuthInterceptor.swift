import Foundation

public final class TokenAuthInterceptor: NetworkInterceptor {
    private let tokenProvider: () -> String?
    private let refreshTokenProvider: () async throws -> String

    public init(
        tokenProvider: @escaping () -> String?,
        refreshTokenProvider: @escaping () async throws -> String
    ) {
        self.tokenProvider = tokenProvider
        self.refreshTokenProvider = refreshTokenProvider
    }

    public func adapt(_ request: URLRequest) async throws -> URLRequest {
        var modifiedRequest = request
        if let token = tokenProvider() {
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return modifiedRequest
    }

    public func retry(_ request: URLRequest, dueTo response: HTTPURLResponse, data _: Data) async throws -> URLRequest? {
        guard response.statusCode == 401 else { return nil }
        let newToken = try await refreshTokenProvider()
        var newRequest = request
        newRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
        return newRequest
    }
}
