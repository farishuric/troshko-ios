import SwiftUI

// MARK: - Link Definition

/// Defines a single tappable link within a `LinkedText` template.
public struct LinkedTextLink {
    /// The token key matching a `{token}` placeholder in the template string.
    public let token: String
    /// The localized display text that replaces the placeholder.
    public let displayText: String
    /// The color applied to this link. Defaults to `.appPrimary` when `nil`.
    public let color: Color?
    /// Whether the link text is underlined. Defaults to `true`.
    public let underline: Bool
    /// The action invoked when the link is tapped.
    public let action: () -> Void

    public init(
        token: String,
        displayText: String,
        color: Color? = nil,
        underline: Bool = true,
        action: @escaping () -> Void
    ) {
        self.token = token
        self.displayText = displayText
        self.color = color
        self.underline = underline
        self.action = action
    }
}

// MARK: - LinkedText

/// A reusable SwiftUI component that renders localized text containing inline
/// tappable links.
///
/// Usage:
/// ```swift
/// LinkedText(
///     template: String(localized: "CONSENT_TEXT"),
///     links: [
///         LinkedTextLink(
///             token: "privacy",
///             displayText: String(localized: "CONSENT_PRIVACY"),
///             action: { showPrivacy = true }
///         ),
///         LinkedTextLink(
///             token: "terms",
///             displayText: String(localized: "CONSENT_TERMS"),
///             action: { showTerms = true }
///         )
///     ]
/// )
/// .font(.regular(.small))
/// ```
///
/// The template string uses `{token}` placeholders:
/// ```
/// "CONSENT_TEXT" = "By continuing, you agree to {privacy} and {terms}";
/// ```
///
/// Each placeholder is replaced with the corresponding link's display text,
/// styled as a tappable link. This approach is safe for localization because
/// translators can reorder `{token}` placeholders freely without breaking
/// the link resolution.
public struct LinkedText: View {
    private let template: String
    private let links: [LinkedTextLink]
    private let defaultLinkColor: Color

    public init(
        template: String,
        links: [LinkedTextLink],
        defaultLinkColor: Color = .accentColor
    ) {
        self.template = template
        self.links = links
        self.defaultLinkColor = defaultLinkColor
    }

    public var body: some View {
        Text(buildAttributedString())
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "linkedtext" else { return .systemAction }
                let token = url.host ?? ""
                if let link = links.first(where: { $0.token == token }) {
                    link.action()
                    return .handled
                }
                return .discarded
            })
    }

    // MARK: - AttributedString Construction

    private func buildAttributedString() -> AttributedString {
        let linksByToken = Dictionary(uniqueKeysWithValues: links.map { ($0.token, $0) })

        // Parse template into segments: alternating plain text and tokens
        let segments = parseTemplate(template)

        var result = AttributedString()

        for segment in segments {
            switch segment {
            case .text(let value):
                result.append(AttributedString(value))

            case .token(let key):
                guard let link = linksByToken[key] else {
                    // Unknown token — render as-is so the developer notices
                    result.append(AttributedString("{\(key)}"))
                    continue
                }

                var attributed = AttributedString(link.displayText)
                let linkColor = link.color ?? defaultLinkColor
                attributed.foregroundColor = linkColor
                if link.underline {
                    attributed.underlineStyle = .single
                }
                // Custom URL scheme maps taps back to the correct closure
                attributed.link = URL(string: "linkedtext://\(link.token)")
                result.append(attributed)
            }
        }

        return result
    }
}

// MARK: - Template Parser

private enum TemplateSegment {
    case text(String)
    case token(String)
}

/// Parses a template string with `{token}` placeholders into an ordered
/// list of segments. Unmatched braces are treated as literal text.
private func parseTemplate(_ template: String) -> [TemplateSegment] {
    var segments: [TemplateSegment] = []
    var current = ""
    var inToken = false
    var tokenContent = ""

    for char in template {
        if inToken {
            if char == "}" {
                if !tokenContent.isEmpty {
                    // Flush any preceding plain text
                    if !current.isEmpty {
                        segments.append(.text(current))
                        current = ""
                    }
                    segments.append(.token(tokenContent))
                } else {
                    // Empty braces: treat as literal
                    current += "{}"
                }
                tokenContent = ""
                inToken = false
            } else {
                tokenContent.append(char)
            }
        } else if char == "{" {
            inToken = true
            tokenContent = ""
        } else {
            current.append(char)
        }
    }

    // Handle unterminated token
    if inToken {
        current += "{\(tokenContent)"
    }

    if !current.isEmpty {
        segments.append(.text(current))
    }

    return segments
}
