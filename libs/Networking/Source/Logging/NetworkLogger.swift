import Foundation

/// Formats and prints network request/response details to the Xcode console.
///
/// Sensitive header values (Authorization, tokens, passwords) are redacted
/// at all logging levels to prevent accidental leaks.
public struct NetworkLogger: Sendable {

    public let level: NetworkLoggingLevel

    public init(level: NetworkLoggingLevel) {
        self.level = level
    }

    // MARK: - Public API

    /// Log a request that is about to be sent.
    public func logRequest(_ request: URLRequest) {
        guard level != .none else { return }

        var lines: [String] = []
        lines.append("╔══════════════════════════════════════")
        lines.append("║ START REQUEST")
        lines.append("╠══════════════════════════════════════")

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        lines.append("║ \(method) \(url)")

        if level == .full, let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            lines.append("║")
            lines.append("║ Headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let displayValue = Self.redactIfSensitive(key: key, value: value)
                lines.append("║   \(key): \(displayValue)")
            }
        }

        if let body = request.httpBody, !body.isEmpty {
            lines.append("║")
            lines.append("║ Body:")
            let bodyString = Self.prettyPrintedJSON(from: body)
            for line in bodyString.components(separatedBy: "\n") {
                lines.append("║   \(line)")
            }
        }

        lines.append("╠══════════════════════════════════════")
        lines.append("║ END REQUEST")
        lines.append("╚══════════════════════════════════════")

        print(lines.joined(separator: "\n"))
    }

    /// Log a response that was received.
    public func logResponse(_ response: HTTPURLResponse?, data: Data?, for request: URLRequest) {
        guard level == .full else { return }

        var lines: [String] = []
        lines.append("╔══════════════════════════════════════")
        lines.append("║ START RESPONSE")
        lines.append("╠══════════════════════════════════════")

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        lines.append("║ \(method) \(url)")

        if let response = response {
            lines.append("║ Status: \(response.statusCode)")
        }

        if let data = data, !data.isEmpty {
            lines.append("║")
            lines.append("║ Body:")
            let bodyString = Self.prettyPrintedJSON(from: data)
            for line in bodyString.components(separatedBy: "\n") {
                lines.append("║   \(line)")
            }
        }

        lines.append("╠══════════════════════════════════════")
        lines.append("║ END RESPONSE")
        lines.append("╚══════════════════════════════════════")

        print(lines.joined(separator: "\n"))
    }

    // MARK: - Private Helpers

    /// Header keys whose values must be redacted in log output.
    private static let sensitiveHeaderKeys: Set<String> = [
        "authorization",
        "token",
        "access-token",
        "refresh-token",
        "x-auth-token",
        "cookie",
        "set-cookie",
        "password",
        "secret",
        "api-key",
        "x-api-key",
    ]

    /// Returns `"[REDACTED]"` for headers whose key matches a sensitive pattern.
    static func redactIfSensitive(key: String, value: String) -> String {
        let lowered = key.lowercased()
        if sensitiveHeaderKeys.contains(lowered)
            || lowered.contains("token")
            || lowered.contains("password")
            || lowered.contains("secret")
            || lowered.contains("auth")
        {
            return "[REDACTED]"
        }
        return value
    }

    /// Attempts to pretty-print `data` as JSON; falls back to a raw UTF-8 string
    /// or a byte-count description when the data is not representable as text.
    static func prettyPrintedJSON(from data: Data) -> String {
        if let json = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
           let string = String(data: pretty, encoding: .utf8)
        {
            return string
        }
        if let raw = String(data: data, encoding: .utf8) {
            return raw
        }
        return "<\(data.count) bytes>"
    }
}
