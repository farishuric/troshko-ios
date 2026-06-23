import Foundation

/// Controls how much network traffic detail is printed to the console.
public enum NetworkLoggingLevel {
    /// No logging at all.
    case none
    /// Logs HTTP method, full URL, and request body (pretty-printed JSON when possible).
    case short
    /// Logs everything from `.short` plus request headers (sensitive values redacted)
    /// and response details (status code, response body).
    case full
}
